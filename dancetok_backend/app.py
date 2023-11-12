import os
import boto3
from dotenv import load_dotenv
from flask import Flask, jsonify, request
from flask_bcrypt import Bcrypt
from flask_login import (
    LoginManager,
    UserMixin,
    login_required,
    login_user,
    logout_user,
    current_user,
)
from flask_sqlalchemy import SQLAlchemy
from werkzeug.utils import secure_filename

load_dotenv()

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///site.db"
app.config["SECRET_KEY"] = os.getenv("FLASK_SECRET_KEY")

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
login_manager = LoginManager()
login_manager.init_app(app)

AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_KEY")
S3_BUCKET = os.getenv("S3_BUCKET")


class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))

    def set_password(self, password):
        self.password_hash = bcrypt.generate_password_hash(password).decode("utf-8")

    def check_password(self, password):
        return bcrypt.check_password_hash(self.password_hash, password)


class Video(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    s3_file_url = db.Column(db.String(200), nullable=False)
    pose_data_url = db.Column(db.String(200), nullable=False)


class Score(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    video_id = db.Column(db.Integer, db.ForeignKey("video.id"), nullable=False)
    score = db.Column(db.Float, nullable=False)

class FeedItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    video_url = db.Column(db.String(200), nullable=False)
    caption = db.Column(db.String(255), nullable=True)
    username = db.Column(db.String(80), nullable=False)


def upload_file_to_s3(file, bucket_name, user_id, filename):
    print(file, bucket_name, user_id, filename)
    s3 = boto3.client(
        "s3",
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY"),
        aws_secret_access_key=os.getenv("AWS_SECRET_KEY"),
    )
    try:
        s3.upload_fileobj(file, bucket_name, f"{user_id}/{filename}")
        return f"https://{bucket_name}.s3.amazonaws.com/{user_id}/{filename}"
    except Exception as e:
        return None


@login_manager.user_loader
def load_user(user_id):
    return db.session.get(User, int(user_id))


@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"error": "Username and password are required"}), 400

    user = User.query.filter_by(username=username).first()
    if user:
        return jsonify({"error": "Username already exists"}), 409

    new_user = User(username=username)
    new_user.set_password(password)

    db.session.add(new_user)
    db.session.commit()

    return jsonify({"message": "User registered successfully"}), 201


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    user = User.query.filter_by(username=username).first()
    if user and user.check_password(password):
        login_user(user)
        return jsonify({"message": "Login successful"}), 200
    else:
        return jsonify({"error": "Invalid credentials"}), 401


@app.route("/logout")
@login_required
def logout():
    logout_user()
    return jsonify({"message": "Logged out"}), 200


@app.route("/get-video/<int:user_id>", methods=["GET"])
def get_video(user_id):
    video = Video.query.filter_by(user_id=user_id).first()
    if video:
        return jsonify({"video_url": video.s3_file_url})
    else:
        return jsonify({"error": "Video not found"}), 404



@app.route("/get-pose-data/<int:user_id>", methods=["GET"])
def get_pose_data(user_id):
    video = Video.query.filter_by(user_id=user_id).first()
    if video:
        return jsonify({"pose_data_url": video.pose_data_url})
    else:
        return jsonify({"error": "Pose data not found"}), 404



@app.route("/put-score", methods=["POST"])
def put_score():
    data = request.get_json()
    print(data)
    user_id = data.get("user_id")  # Get user_id from the request data
    video_id = data.get("video_id")
    score = data.get("score")

    if not all([user_id, video_id, score]):
        return jsonify({"error": "Missing user_id, video_id, or score"}), 400

    new_score = Score(video_id=video_id, score=score)
    db.session.add(new_score)
    db.session.commit()

    return jsonify({"message": "Score added successfully"})



@login_required
@app.route("/get-score/<int:video_id>", methods=["GET"])
def get_score(video_id):
    scores = Score.query.filter_by(video_id=video_id).all()
    return jsonify(
        {"scores": [{"id": score.id, "video-id": score.video_id, "score": score.score} for score in scores]}
    )


@login_required
@app.route("/top-scores", methods=["GET"])
def top_scores():
    scores = Score.query.order_by(Score.score.desc()).limit(10).all()
    return jsonify(
        {
            "top_scores": [
                {"video_id": score.video_id, "score": score.score} for score in scores
            ]
        }
    )


@login_required
@app.route("/put-video", methods=["POST"])
def put_video():
    user_id = 1
    if "video" not in request.files:
        return jsonify({"error": "No video file provided"}), 400

    file = request.files["video"]

    if file.filename == "":
        return jsonify({"error": "No video file provided"}), 400

    if not file:
        return jsonify({"error": "Failed to upload pose data"}), 500

    filename = secure_filename(file.filename)

    # Assuming upload_file_to_s3 is a function you've defined to upload files to S3
    s3_url = upload_file_to_s3(file, S3_BUCKET, user_id, filename)

    if s3_url:
        # Assuming Video is a model you've defined
        video = Video(user_id=user_id, s3_file_url=s3_url, pose_data_url="")
        db.session.add(video)
        db.session.commit()
        return jsonify({"message": "Video uploaded successfully", "url": s3_url})
    else:
        return jsonify({"error": "Failed to upload video"}), 500



@login_required
@app.route("/put-pose-data", methods=["POST"])
def put_pose_data():
    user_id = 1
    if "pose_data" not in request.files:
        return jsonify({"error": "No pose data file provided"}), 400

    file = request.files["pose_data"]
    if file.filename == "":
        return jsonify({"error": "No pose data file provided"}), 400

    filename = secure_filename(file.filename)
    s3_url = upload_file_to_s3(file, S3_BUCKET, user_id, filename)
    if s3_url:
        video = Video.query.filter_by(user_id=user_id).first()
        if video:
            video.pose_data_url = s3_url
            db.session.commit()
            return jsonify(
                {"message": "Pose data uploaded successfully", "url": s3_url}
            )
        else:
            return jsonify({"error": "Video record not found for user"}), 404
    else:
        return jsonify({"error": "Failed to upload pose data"}), 500


def populate_feed():
    items = [
        FeedItem(video_url="https://youtube.com/shorts/lk10MSbrs-w?feature=shared", caption="Dance Video 1", username="user1"),
        FeedItem(video_url="https://youtube.com/shorts/lk10MSbrs-w?feature=shared", caption="Dance Video 2", username="user2"),
    ]
    db.session.bulk_save_objects(items)
    db.session.commit()


@app.route("/feed", methods=["GET"])
def get_feed():
    # populate_feed()
    feed_items = FeedItem.query.all()
    feed_data = [
        {"video_url": item.video_url, "caption": item.caption, "username": item.username}
        for item in feed_items
    ]
    return jsonify({"feed": feed_data})


if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(debug=True, port=5002)
