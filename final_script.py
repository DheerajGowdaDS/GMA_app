import cv2
import mediapipe as mp
import numpy as np


class BabyVideoValidator:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.mp_face = mp.solutions.face_detection
        self.mp_drawing = mp.solutions.drawing_utils

        # Initialize pose estimation
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            model_complexity=1,
            smooth_landmarks=True,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )

        # Initialize face detection
        self.face_detection = self.mp_face.FaceDetection(
            min_detection_confidence=0.5
        )

        # Simple thresholds
        self.min_brightness = 50
        self.max_brightness = 200
        self.min_landmarks = 30  # Need at least 30 visible landmarks

        # Smart bounding box parameters
        self.established_bbox = None  # The established boundary
        self.buffer_distance = 50  # Fixed buffer distance from landmarks
        self.stretch_threshold = 5  # How far baby needs to stretch to expand box
        self.initialization_frames = 30  # Frames to observe before establishing box
        self.frame_count = 0
        self.landmark_history = []  # Store landmark positions for initialization

    def collect_landmark_positions(self, pose_results, face_results, frame_shape):
        """Collect all current landmark positions"""
        height, width = frame_shape[:2]
        positions = []

        # Collect pose landmarks
        if pose_results and pose_results.pose_landmarks:
            for landmark in pose_results.pose_landmarks.landmark:
                if landmark.visibility > 0.5:
                    positions.append({
                        'x': landmark.x * width,
                        'y': landmark.y * height,
                        'type': 'pose'
                    })

        # Collect face landmarks
        if face_results and face_results.detections:
            for detection in face_results.detections:
                bbox = detection.location_data.relative_bounding_box
                # Add face corners as landmarks
                positions.extend([
                    {'x': bbox.xmin * width, 'y': bbox.ymin * height, 'type': 'face'},
                    {'x': (bbox.xmin + bbox.width) * width, 'y': bbox.ymin * height, 'type': 'face'},
                    {'x': bbox.xmin * width, 'y': (bbox.ymin + bbox.height) * height, 'type': 'face'},
                    {'x': (bbox.xmin + bbox.width) * width, 'y': (bbox.ymin + bbox.height) * height, 'type': 'face'}
                ])

        return positions

    def establish_boundary_box(self):
        """Establish the boundary box based on collected landmark history"""
        if len(self.landmark_history) < self.initialization_frames:
            return None

        # Flatten all landmark positions from history
        all_x_coords = []
        all_y_coords = []

        for frame_landmarks in self.landmark_history:
            for pos in frame_landmarks:
                all_x_coords.append(pos['x'])
                all_y_coords.append(pos['y'])

        if len(all_x_coords) < 20:  # Need sufficient data
            return None

        # Find the extreme positions across all frames
        min_x = min(all_x_coords)
        max_x = max(all_x_coords)
        min_y = min(all_y_coords)
        max_y = max(all_y_coords)

        # Add buffer distance to create the boundary
        boundary_box = {
            'x1': int(min_x - self.buffer_distance),
            'y1': int(min_y - self.buffer_distance),
            'x2': int(max_x + self.buffer_distance),
            'y2': int(max_y + self.buffer_distance)
        }

        return boundary_box

    def check_if_stretching(self, current_positions, frame_shape):
        """Check if baby is stretching beyond the established boundary"""
        if not self.established_bbox or not current_positions:
            return False, self.established_bbox

        height, width = frame_shape[:2]
        bbox = self.established_bbox.copy()
        box_expanded = False

        # Check each current landmark position
        for pos in current_positions:
            x, y = pos['x'], pos['y']

            # Check if landmark is stretching beyond boundary + threshold
            if x < (bbox['x1'] - self.stretch_threshold):
                bbox['x1'] = max(0, int(x - self.buffer_distance))
                box_expanded = True
            elif x > (bbox['x2'] + self.stretch_threshold):
                bbox['x2'] = min(width, int(x + self.buffer_distance))
                box_expanded = True

            if y < (bbox['y1'] - self.stretch_threshold):
                bbox['y1'] = max(0, int(y - self.buffer_distance))
                box_expanded = True
            elif y > (bbox['y2'] + self.stretch_threshold):
                bbox['y2'] = min(height, int(y + self.buffer_distance))
                box_expanded = True

        # Update established box if it expanded
        if box_expanded:
            self.established_bbox = bbox

        return box_expanded, bbox

    def get_smart_bounding_box(self, pose_results, face_results, frame_shape):
        """Get smart bounding box that only adjusts when baby stretches"""
        self.frame_count += 1
        current_positions = self.collect_landmark_positions(pose_results, face_results, frame_shape)

        # Phase 1: Initialization - collect landmark data
        if self.frame_count <= self.initialization_frames:
            if current_positions:
                self.landmark_history.append(current_positions)
            return None, "INITIALIZING", len(self.landmark_history)

        # Phase 2: Establish boundary box (one time)
        if self.established_bbox is None:
            self.established_bbox = self.establish_boundary_box()
            if self.established_bbox is None:
                return None, "INITIALIZATION_FAILED", 0
            return self.established_bbox, "BOUNDARY_ESTABLISHED", 0

        # Phase 3: Monitor for stretching
        if not current_positions:
            return self.established_bbox, "NO_LANDMARKS", 0

        stretched, current_bbox = self.check_if_stretching(current_positions, frame_shape)

        if stretched:
            return current_bbox, "STRETCHED_AND_EXPANDED", 0
        else:
            return self.established_bbox, "STABLE", 0

    def is_bbox_in_frame(self, bbox, frame_shape):
        """Check if entire bounding box is within frame"""
        if not bbox:
            return False

        height, width = frame_shape[:2]
        return (bbox['x1'] >= 0 and bbox['y1'] >= 0 and
                bbox['x2'] <= width and bbox['y2'] <= height)

    def check_lighting(self, frame):
        """Simple lighting check"""
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        brightness = np.mean(gray)
        return self.min_brightness <= brightness <= self.max_brightness

    def count_visible_landmarks(self, pose_results):
        """Count visible landmarks"""
        if not pose_results or not pose_results.pose_landmarks:
            return 0

        count = 0
        for landmark in pose_results.pose_landmarks.landmark:
            if landmark.visibility > 0.5:
                count += 1
        return count

    def validate_frame(self, frame):
        """Main validation for single frame"""
        # Convert to RGB for MediaPipe
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        pose_results = self.pose.process(rgb_frame)
        face_results = self.face_detection.process(rgb_frame)

        # Get smart bounding box
        bbox, box_status, init_progress = self.get_smart_bounding_box(pose_results, face_results, frame.shape)

        # Check conditions
        lighting_ok = self.check_lighting(frame)
        bbox_in_frame = self.is_bbox_in_frame(bbox, frame.shape) if bbox else False
        enough_landmarks = self.count_visible_landmarks(pose_results) >= self.min_landmarks

        # Overall pass/fail (only after initialization)
        if bbox is None:
            frame_passed = False
        else:
            frame_passed = lighting_ok and bbox_in_frame and enough_landmarks

        return {
            'pose_results': pose_results,
            'face_results': face_results,
            'bbox': bbox,
            'box_status': box_status,
            'init_progress': init_progress,
            'lighting_ok': lighting_ok,
            'bbox_in_frame': bbox_in_frame,
            'visible_landmarks': self.count_visible_landmarks(pose_results),
            'frame_passed': frame_passed
        }

    def draw_overlay(self, frame, result):
        """Draw validation overlay on frame"""
        overlay = frame.copy()

        # Draw bounding box if available
        if result['bbox']:
            bbox = result['bbox']

            # Color based on box status
            if result['box_status'] == "STRETCHED_AND_EXPANDED":
                color = (0, 255, 255)  # Yellow for expansion
            elif result['frame_passed']:
                color = (0, 255, 0)  # Green for pass
            else:
                color = (0, 0, 255)  # Red for fail

            # Draw main bounding box
            cv2.rectangle(overlay,
                          (bbox['x1'], bbox['y1']),
                          (bbox['x2'], bbox['y2']),
                          color, 2)

            # Draw center point
            center_x = (bbox['x1'] + bbox['x2']) // 2
            center_y = (bbox['y1'] + bbox['y2']) // 2
            cv2.circle(overlay, (center_x, center_y), 5, color, -1)

        # Draw pose landmarks
        if result['pose_results'] and result['pose_results'].pose_landmarks:
            self.mp_drawing.draw_landmarks(
                overlay,
                result['pose_results'].pose_landmarks,
                self.mp_pose.POSE_CONNECTIONS
            )

        # Status text
        if result['box_status'] == "INITIALIZING":
            status = f"INITIALIZING ({result['init_progress']}/{self.initialization_frames})"
            status_color = (255, 255, 0)  # Blue
        elif result['frame_passed']:
            status = "PASS"
            status_color = (0, 255, 0)
        else:
            status = "FAIL"
            status_color = (0, 0, 255)

        cv2.putText(overlay, status, (10, 40), cv2.FONT_HERSHEY_SIMPLEX, 1.2, status_color, 3)

        # Box status
        cv2.putText(overlay, f"Box: {result['box_status']}",
                    (10, 70), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

        # Details
        cv2.putText(overlay, f"Lighting: {'OK' if result['lighting_ok'] else 'FAIL'}",
                    (10, 100), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.putText(overlay, f"BBox in frame: {'YES' if result['bbox_in_frame'] else 'NO'}",
                    (10, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.putText(overlay, f"Landmarks: {result['visible_landmarks']}",
                    (10, 160), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

        return overlay

    def validate_video(self, video_path):
        """Validate entire video with display"""
        cap = cv2.VideoCapture(video_path)

        if not cap.isOpened():
            print("Could not open video")
            return

        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        fps = cap.get(cv2.CAP_PROP_FPS)
        frame_count = 0
        passed_frames = 0

        print("Press 'q' to quit, 'p' to pause")
        print("Box will initialize for first 30 frames, then become stable")
        paused = False

        while True:
            if not paused:
                ret, frame = cap.read()
                if not ret:
                    break

                frame_count += 1
                result = self.validate_frame(frame)

                if result['frame_passed']:
                    passed_frames += 1

                # Display frame with overlay
                display_frame = self.draw_overlay(frame, result)

                # Add frame counter and timestamp
                timestamp = frame_count / fps if fps > 0 else 0
                cv2.putText(display_frame, f"Frame: {frame_count}/{total_frames}",
                            (display_frame.shape[1] - 250, 30),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
                cv2.putText(display_frame, f"Time: {timestamp:.1f}s",
                            (display_frame.shape[1] - 250, 60),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

                if frame_count > self.initialization_frames:
                    cv2.putText(display_frame,
                                f"Pass Rate: {(passed_frames / (frame_count - self.initialization_frames)) * 100:.1f}%",
                                (display_frame.shape[1] - 250, 90),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

                cv2.imshow('Baby Video Validation', display_frame)

            # Handle keys
            key = cv2.waitKey(30) & 0xFF
            if key == ord('q'):
                break
            elif key == ord('p'):
                paused = not paused

        cap.release()
        cv2.destroyAllWindows()

        # Final results
        valid_frames = frame_count - self.initialization_frames
        pass_rate = passed_frames / valid_frames if valid_frames > 0 else 0
        print(f"\nResults:")
        print(f"Total frames: {frame_count}")
        print(f"Initialization frames: {self.initialization_frames}")
        print(f"Valid frames: {valid_frames}")
        print(f"Passed frames: {passed_frames}")
        print(f"Pass rate: {pass_rate:.1%}")
        print(f"Overall: {'PASS' if pass_rate >= 0.8 else 'FAIL'}")

    def live_camera_test(self):
        """Test with live camera"""
        cap = cv2.VideoCapture(0)

        if not cap.isOpened():
            print("Camera not found")
            return

        print("Live camera test - Press 'q' to quit")
        print("Keep baby in view for first 30 frames to establish boundary")

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            result = self.validate_frame(frame)
            display_frame = self.draw_overlay(frame, result)

            cv2.imshow('Live Baby Test', display_frame)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

        cap.release()
        cv2.destroyAllWindows()


def main():
    validator = BabyVideoValidator()

    choice = input("1. Video file\n2. Live camera\nChoose: ")

    if choice == "2":
        validator.live_camera_test()
    else:
        video_path = input("Enter video path: ")
        validator.validate_video(video_path)


if __name__ == "__main__":
    main()