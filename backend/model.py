import cv2
import mediapipe as mp
import numpy as np


class BabyVideoValidator:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.mp_face = mp.solutions.face_detection
        self.mp_drawing = mp.solutions.drawing_utils

        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            model_complexity=1,
            smooth_landmarks=True,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )

        self.face_detection = self.mp_face.FaceDetection(min_detection_confidence=0.5)

        # Thresholds
        self.min_brightness = 50
        self.max_brightness = 200
        self.min_landmarks = 30

        # Bounding box and tracking
        self.established_bbox = None
        self.buffer_distance = 50
        self.stretch_threshold = 5
        self.initialization_frames = 30
        self.frame_count = 0
        self.landmark_history = []

    def collect_landmark_positions(self, pose_results, face_results, frame_shape):
        height, width = frame_shape[:2]
        positions = []

        if pose_results and pose_results.pose_landmarks:
            for landmark in pose_results.pose_landmarks.landmark:
                if landmark.visibility > 0.5:
                    positions.append({
                        'x': landmark.x * width,
                        'y': landmark.y * height,
                        'type': 'pose'
                    })

        if face_results and face_results.detections:
            for detection in face_results.detections:
                bbox = detection.location_data.relative_bounding_box
                positions.extend([
                    {'x': bbox.xmin * width, 'y': bbox.ymin * height, 'type': 'face'},
                    {'x': (bbox.xmin + bbox.width) * width, 'y': bbox.ymin * height, 'type': 'face'},
                    {'x': bbox.xmin * width, 'y': (bbox.ymin + bbox.height) * height, 'type': 'face'},
                    {'x': (bbox.xmin + bbox.width) * width, 'y': (bbox.ymin + bbox.height) * height, 'type': 'face'}
                ])
        return positions

    def establish_boundary_box(self):
        if len(self.landmark_history) < self.initialization_frames:
            return None

        all_x, all_y = [], []
        for frame_landmarks in self.landmark_history:
            for pos in frame_landmarks:
                all_x.append(pos['x'])
                all_y.append(pos['y'])

        if len(all_x) < 20:
            return None

        min_x, max_x = min(all_x), max(all_x)
        min_y, max_y = min(all_y), max(all_y)

        return {
            'x1': int(min_x - self.buffer_distance),
            'y1': int(min_y - self.buffer_distance),
            'x2': int(max_x + self.buffer_distance),
            'y2': int(max_y + self.buffer_distance)
        }

    def check_if_stretching(self, current_positions, frame_shape):
        if not self.established_bbox or not current_positions:
            return False, self.established_bbox

        height, width = frame_shape[:2]
        bbox = self.established_bbox.copy()
        expanded = False

        for pos in current_positions:
            x, y = pos['x'], pos['y']

            if x < bbox['x1'] - self.stretch_threshold:
                bbox['x1'] = max(0, int(x - self.buffer_distance))
                expanded = True
            elif x > bbox['x2'] + self.stretch_threshold:
                bbox['x2'] = min(width, int(x + self.buffer_distance))
                expanded = True

            if y < bbox['y1'] - self.stretch_threshold:
                bbox['y1'] = max(0, int(y - self.buffer_distance))
                expanded = True
            elif y > bbox['y2'] + self.stretch_threshold:
                bbox['y2'] = min(height, int(y + self.buffer_distance))
                expanded = True

        if expanded:
            self.established_bbox = bbox

        return expanded, bbox

    def get_smart_bounding_box(self, pose_results, face_results, frame_shape):
        self.frame_count += 1
        current_positions = self.collect_landmark_positions(pose_results, face_results, frame_shape)

        if self.frame_count <= self.initialization_frames:
            if current_positions:
                self.landmark_history.append(current_positions)
            return None, "INITIALIZING", len(self.landmark_history)

        if self.established_bbox is None:
            self.established_bbox = self.establish_boundary_box()
            if self.established_bbox is None:
                return None, "INITIALIZATION_FAILED", 0
            return self.established_bbox, "BOUNDARY_ESTABLISHED", 0

        if not current_positions:
            return self.established_bbox, "NO_LANDMARKS", 0

        stretched, current_bbox = self.check_if_stretching(current_positions, frame_shape)
        return (current_bbox, "STRETCHED_AND_EXPANDED", 0) if stretched else (self.established_bbox, "STABLE", 0)

    def is_bbox_in_frame(self, bbox, frame_shape):
        if not bbox:
            return False
        h, w = frame_shape[:2]
        return (0 <= bbox['x1'] < bbox['x2'] <= w) and (0 <= bbox['y1'] < bbox['y2'] <= h)

    def check_lighting(self, frame):
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        brightness = np.mean(gray)
        return self.min_brightness <= brightness <= self.max_brightness

    def count_visible_landmarks(self, pose_results):
        if not pose_results or not pose_results.pose_landmarks:
            return 0
        return sum(1 for lm in pose_results.pose_landmarks.landmark if lm.visibility > 0.5)

    def validate_frame(self, frame):
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        pose = self.pose.process(rgb)
        face = self.face_detection.process(rgb)

        bbox, box_status, init_progress = self.get_smart_bounding_box(pose, face, frame.shape)

        lighting_ok = self.check_lighting(frame)
        bbox_in_frame = self.is_bbox_in_frame(bbox, frame.shape) if bbox else False
        landmarks_count = self.count_visible_landmarks(pose)
        enough_landmarks = landmarks_count >= self.min_landmarks
        frame_passed = lighting_ok and bbox_in_frame and enough_landmarks if bbox else False

        return {
            'pose_results': pose,
            'face_results': face,
            'bbox': bbox,
            'box_status': box_status,
            'init_progress': init_progress,
            'lighting_ok': lighting_ok,
            'bbox_in_frame': bbox_in_frame,
            'visible_landmarks': landmarks_count,
            'frame_passed': frame_passed
        }

    def draw_overlay(self, frame, result):
        overlay = frame.copy()

        # Bounding box and center
        if result['bbox']:
            bbox = result['bbox']
            color = (0, 255, 255) if result['box_status'] == "STRETCHED_AND_EXPANDED" else \
                    (0, 255, 0) if result['frame_passed'] else (0, 0, 255)

            cv2.rectangle(overlay, (bbox['x1'], bbox['y1']), (bbox['x2'], bbox['y2']), color, 2)
            cx = (bbox['x1'] + bbox['x2']) // 2
            cy = (bbox['y1'] + bbox['y2']) // 2
            cv2.circle(overlay, (cx, cy), 5, color, -1)

        # Pose landmarks
        if result['pose_results'] and result['pose_results'].pose_landmarks:
            self.mp_drawing.draw_landmarks(overlay, result['pose_results'].pose_landmarks, self.mp_pose.POSE_CONNECTIONS)

        # Status messages
        status_text = "INITIALIZING" if result['box_status'] == "INITIALIZING" else "PASS" if result['frame_passed'] else "FAIL"
        status_color = (255, 255, 0) if status_text == "INITIALIZING" else (0, 255, 0) if status_text == "PASS" else (0, 0, 255)

        cv2.putText(overlay, status_text, (10, 40), cv2.FONT_HERSHEY_SIMPLEX, 1.2, status_color, 3)
        cv2.putText(overlay, f"Box: {result['box_status']}", (10, 70), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.putText(overlay, f"Lighting: {'OK' if result['lighting_ok'] else 'FAIL'}", (10, 100), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.putText(overlay, f"BBox in frame: {'YES' if result['bbox_in_frame'] else 'NO'}", (10, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.putText(overlay, f"Landmarks: {result['visible_landmarks']}", (10, 160), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

        return overlay

    def validate_video(self, video_path):
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            print("[ERROR] Cannot open video file.")
            return

        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        fps = cap.get(cv2.CAP_PROP_FPS)
        frame_idx = 0
        passed_frames = 0

        print("Analyzing video...")
        while True:
            ret, frame = cap.read()
            if not ret:
                break

            frame_idx += 1
            result = self.validate_frame(frame)
            if result['frame_passed']:
                passed_frames += 1

            display = self.draw_overlay(frame, result)

            timestamp = frame_idx / fps if fps > 0 else 0
            cv2.putText(display, f"Frame: {frame_idx}/{total_frames}", (display.shape[1] - 250, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
            cv2.putText(display, f"Time: {timestamp:.1f}s", (display.shape[1] - 250, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

            if frame_idx > self.initialization_frames:
                valid_frames = frame_idx - self.initialization_frames
                pass_rate = (passed_frames / valid_frames) * 100
                cv2.putText(display, f"Pass Rate: {pass_rate:.1f}%", (display.shape[1] - 250, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

            cv2.imshow("Baby Video Validation", display)
            if cv2.waitKey(30) & 0xFF == ord('q'):
                break

        cap.release()
        cv2.destroyAllWindows()

        valid = frame_idx - self.initialization_frames
        pass_rate = passed_frames / valid if valid > 0 else 0
        print("\n--- FINAL REPORT ---")
        print(f"Total frames: {frame_idx}")
        print(f"Initialization frames: {self.initialization_frames}")
        print(f"Valid frames: {valid}")
        print(f"Passed frames: {passed_frames}")
        print(f"Pass rate: {pass_rate:.1%}")
        print(f"Result: {'PASS' if pass_rate >= 0.8 else 'FAIL'}")