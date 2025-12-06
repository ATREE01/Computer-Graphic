import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;

public Vector4 renderer_size;
static public float GH_FOV = 45.0f;
static public float GH_NEAR_MIN = 1e-3f;
static public float GH_NEAR_MAX = 1e-1f;
static public float GH_FAR = 1000.0f;

public boolean debug = true;

public float[] GH_DEPTH;
public PImage renderBuffer;

Engine engine;
Camera main_camera;
Vector3 cam_position;
Vector3 lookat;

void setup() {
    size(1000, 600);
    renderer_size = new Vector4(20, 50, 520, 550);
    cam_position = new Vector3(0, 0, -10);
    lookat = new Vector3(0, 0, 0);
    setDepthBuffer();
    main_camera = new Camera();
    engine = new Engine();

}

void setDepthBuffer(){
    renderBuffer = new PImage(int(renderer_size.z - renderer_size.x) , int(renderer_size.w - renderer_size.y));
    GH_DEPTH = new float[int(renderer_size.z - renderer_size.x) * int(renderer_size.w - renderer_size.y)];
    for(int i = 0 ; i < GH_DEPTH.length;i++){
        GH_DEPTH[i] = 1.0;
        renderBuffer.pixels[i] = color(1.0*250);
    }
}

void draw() {
    background(255);

    engine.run();
    cameraControl();
}

String selectFile() {
    JFileChooser fileChooser = new JFileChooser();
    fileChooser.setCurrentDirectory(new File("."));
    fileChooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
    FileNameExtensionFilter filter = new FileNameExtensionFilter("Obj Files", "obj");
    fileChooser.setFileFilter(filter);

    int result = fileChooser.showOpenDialog(null);
    if (result == JFileChooser.APPROVE_OPTION) {
        String filePath = fileChooser.getSelectedFile().getAbsolutePath();
        return filePath;
    }
    return "";
}

// Camera Angles
float cam_yaw   = -90.0f; // Start looking at -Z (Into the screen)
float cam_pitch = 0.0f;   // Start looking level

void cameraControl() {
    float moveSpeed   = 0.2f;  // How fast you move
    float mouseSensitivity = 0.5f; // How fast you look around

    // --- 1. MOUSE LOOK (Pitch & Yaw) ---
    // We update angles only when mouse is pressed (to avoid spinning when checking UI)
    if (mousePressed) {
        float dx = (mouseX - pmouseX) * mouseSensitivity;
        float dy = (mouseY - pmouseY) * mouseSensitivity;

        cam_yaw   += dx;
        cam_pitch -= dy; // Inverted Y: Moving mouse Up (negative Y) increases Pitch (look up)

        // Clamp Pitch so you can't backflip (Standard FPS limit)
        if (cam_pitch > 89.0f)  cam_pitch = 89.0f;
        if (cam_pitch < -89.0f) cam_pitch = -89.0f;
    }

    // --- 2. CALCULATE VECTORS ---
    // Convert angles (degrees) to a Forward Vector (Direction)
    float radYaw   = (float)Math.toRadians(cam_yaw);
    float radPitch = (float)Math.toRadians(cam_pitch);

    // Spherical to Cartesian Coordinates conversion
    Vector3 front = new Vector3();
    front.set(
        (float)(Math.cos(radYaw) * Math.cos(radPitch)),
        (float)Math.sin(radPitch),
        (float)(Math.sin(radYaw) * Math.cos(radPitch))
    );
    Vector3 forward = front.unit_vector();

    // Calculate Right Vector (Cross Product of Forward and World Up)
    Vector3 right = Vector3.cross(forward, Vector3.UnitY()).unit_vector();
    
    // Calculate Up Vector (Camera's local up)
    Vector3 up = Vector3.cross(right, forward).unit_vector();


    // --- 3. KEYBOARD MOVEMENT ---
    if (keyPressed) {
        // W: Move Forward
        if (key == 'w' || key == 'W') {
            cam_position = cam_position.add(forward.mult(moveSpeed));
        }
        // S: Move Backward
        if (key == 's' || key == 'S') {
            cam_position = cam_position.sub(forward.mult(moveSpeed));
        }
        // A: Strafe Left
        if (key == 'a' || key == 'A') {
            cam_position = cam_position.sub(right.mult(moveSpeed));
        }
        // D: Strafe Right
        if (key == 'd' || key == 'D') {
            cam_position = cam_position.add(right.mult(moveSpeed));
        }
        
        // OPTIONAL: Fly Up/Down
        // Space to go Up
        if (key == ' ') {
            cam_position = cam_position.add(Vector3.UnitY().mult(moveSpeed));
        }
        // Shift (or 'c') to go Down
        if (keyCode == SHIFT || key == 'c') {
            cam_position = cam_position.sub(Vector3.UnitY().mult(moveSpeed));
        }
    }

    // --- 4. UPDATE CAMERA MATRIX ---
    // FPS Camera looks at "Position + Direction"
    Vector3 target = cam_position.add(forward);
    main_camera.setPositionOrientation(cam_position, target);
}
