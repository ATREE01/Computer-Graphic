public class Camera {
    Matrix4 projection = new Matrix4();
    Matrix4 worldView = new Matrix4();
    int wid;
    int hei;
    float near;
    float far;
    Transform transform;

    Camera() {
        wid = 256;
        hei = 256;
        worldView.makeIdentity();
        projection.makeIdentity();
        transform = new Transform();
    }

    Matrix4 inverseProjection() {
        Matrix4 invProjection = Matrix4.Zero();
        float a = projection.m[0];
        float b = projection.m[5];
        float c = projection.m[10];
        float d = projection.m[11];
        float e = projection.m[14];
        invProjection.m[0] = 1.0f / a;
        invProjection.m[5] = 1.0f / b;
        invProjection.m[11] = 1.0f / e;
        invProjection.m[14] = 1.0f / d;
        invProjection.m[15] = -c / (d * e);
        return invProjection;
    }

    Matrix4 Matrix() {
        return projection.mult(worldView);
    }

    void setSize(int w, int h, float n, float f) {
        wid = w;
        hei = h;
        near = n;
        far = f;
        
        // TODO HW3
        // This function takes four parameters, which are 
        // the width of the screen, the height of the screen
        // the near plane and the far plane of the camera.
        // Where GH_FOV has been declared as a global variable.
        // Finally, pass the result into projection matrix.

        projection = Matrix4.Identity();
        float aspect = (float)w / (float)h;
        float fovRad = radians(GH_FOV);
        float tanHalfFov = tan(fovRad / 2.0f);
        
        projection.m[0] = 1.0f / (aspect * tanHalfFov);
        projection.m[5] = 1.0f / tanHalfFov;
        projection.m[10] = (far + near) / (near - far);
        projection.m[11] = (2 * far * near) / (near - far);
        projection.m[14] = -1.0f;
        projection.m[15] = 0.0f;

    }

    void setPositionOrientation(Vector3 pos, float rotX, float rotY) {

    }

    void setPositionOrientation(Vector3 pos, Vector3 lookat) {
        // TODO HW3
        // This function takes two parameters, which are the position of the camera and
        // the point the camera is looking at.
        // We uses topVector = (0,1,0) to calculate the eye matrix.
        // Finally, pass the result into worldView matrix.

        Vector3 topVector = new Vector3(0, 1, 0); 

        worldView = Matrix4.Identity();
        Vector3 zaxis = pos.sub(lookat); // forward
        zaxis.normalize();
        Vector3 xaxis = Vector3.cross(topVector, zaxis);
        xaxis.normalize();
        Vector3 yaxis = Vector3.cross(zaxis, xaxis);
        
        worldView.m[0] = xaxis.x; worldView.m[1] = xaxis.y; worldView.m[2] = xaxis.z; worldView.m[3] = -Vector3.dot(xaxis, pos);
        worldView.m[4] = yaxis.x; worldView.m[5] = yaxis.y; worldView.m[6] = yaxis.z; worldView.m[7] = -Vector3.dot(yaxis, pos);
        worldView.m[8] = zaxis.x; worldView.m[9] = zaxis.y; worldView.m[10] = zaxis.z; worldView.m[11] = -Vector3.dot(zaxis, pos);
        worldView.m[12] = 0; worldView.m[13] = 0; worldView.m[14] = 0; worldView.m[15] = 1;
    }
}
