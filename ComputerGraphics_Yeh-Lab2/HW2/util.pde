public void CGLine(float x1, float y1, float x2, float y2) {
    // TODO HW1
    // Please paste your code from HW1 CGLine.
    int xStart = Math.round(x1);
    int yStart = Math.round(y1);
    int xEnd   = Math.round(x2);
    int yEnd   = Math.round(y2);

    int dx = xEnd - xStart;
    int dy = yEnd - yStart;

    int sx = (dx >= 0) ? 1 : -1;
    int sy = (dy >= 0) ? 1 : -1;

    dx = Math.abs(dx);
    dy = Math.abs(dy);

    int x = xStart;
    int y = yStart;

    // Shallow slope (dx >= dy)
    if (dx >= dy) {
        int d = 2 * dy - dx;      // decision variable
        int incrE = 2 * dy;       // increment if choosing E
        int incrNE = 2 * (dy - dx); // increment if choosing NE

        drawPoint(x, y, color(255, 0, 0));

        for (int i = 0; i < dx; i++) {
            if (d <= 0) {
                // choose E
                d += incrE;
                x += sx;
            } else {
                // choose NE
                d += incrNE;
                x += sx;
                y += sy;
            }
            drawPoint(x, y, color(0, 0, 255));
        }
    } 
    // Steep slope (dy > dx)
    else {
        int d = 2 * dx - dy;
        int incrN = 2 * dx;
        int incrNE = 2 * (dx - dy);

        drawPoint(x, y, color(0, 0, 255));

        for (int i = 0; i < dy; i++) {
            if (d <= 0) {
                // choose N
                d += incrN;
                y += sy;
            } else {
                // choose NE
                d += incrNE;
                x += sx;
                y += sy;
            }
            drawPoint(x, y, color(0, 0, 255));
        }
    }
}

public boolean outOfBoundary(float x, float y) {
    if (x < 0 || x >= width || y < 0 || y >= height)
        return true;
    return false;
}

public void drawPoint(float x, float y, color c) {
    int index = (int) y * width + (int) x;
    if (outOfBoundary(x, y))
        return;
    pixels[index] = c;
}

public float distance(Vector3 a, Vector3 b) {
    Vector3 c = a.sub(b);
    return sqrt(Vector3.dot(c, c));
}

boolean pnpoly(float x, float y, Vector3[] vertexes) {
  int n = vertexes.length;
  boolean inside = false;
  
  for (int i = 0, j = n - 1; i < n; j = i++) {
    float xi = vertexes[i].x;
    float yi = vertexes[i].y;
    float xj = vertexes[j].x;
    float yj = vertexes[j].y;
    
    // 判斷射線是否跨越邊界
    boolean intersect = ((yi > y) != (yj > y)) &&
                        (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }
  
  return inside;
}


public Vector3[] findBoundBox(Vector3[] v) {
    if (v == null || v.length == 0) {
        return new Vector3[]{new Vector3(0, 0, 0), new Vector3(0, 0, 0)};
    }

    float minX = v[0].x;
    float minY = v[0].y;
    float maxX = v[0].x;
    float maxY = v[0].y;

    for (int i = 1; i < v.length; i++) {
        if (v[i].x < minX) {
            minX = v[i].x;
        }
        if (v[i].y < minY) {
            minY = v[i].y;
        }
        if (v[i].x > maxX) {
            maxX = v[i].x;
        }
        if (v[i].y > maxY) {
            maxY = v[i].y;
        }
    }

    Vector3 r1 = new Vector3(minX, minY, 0);
    Vector3 r2 = new Vector3(maxX, maxY, 0);

    return new Vector3[]{r1, r2};
}

public Vector3[] Sutherland_Hodgman_algorithm(Vector3[] points, Vector3[] boundary) {
    ArrayList<Vector3> input = new ArrayList<Vector3>();
    for (int i = 0; i < points.length; i += 1) {
        input.add(points[i]);
    }

    // This list will hold the vertices from the previous clip edge
    // It starts as the original polygon
    ArrayList<Vector3> output = new ArrayList<Vector3>(input);

    // TODO HW2
    // You need to implement the Sutherland Hodgman Algorithm in this section.
    
    // Loop through each edge of the *boundary* polygon
    int boundaryN = boundary.length;
    for (int i = 0; i < boundaryN; i++) {
        // Get the two vertices of the current boundary edge
        Vector3 P1 = boundary[i];
        Vector3 P2 = boundary[(i + 1) % boundaryN]; // Wrap around to the start

        // 'nextInput' will store the vertices for the *next* clipping stage
        ArrayList<Vector3> nextInput = new ArrayList<Vector3>();
        
        // Loop through each edge of the *subject* polygon (the current 'output')
        int outputN = output.size();
        if (outputN == 0) {
            break; // No polygon left to clip
        }

        for (int j = 0; j < outputN; j++) {
            // Get the two vertices of the current subject edge
            Vector3 S = output.get(j);
            Vector3 E = output.get((j + 1) % outputN); // Wrap around

            // Check if start and end points are "inside" the boundary edge
            // (Assuming CCW boundary, "inside" is to the left)
            boolean s_inside = isInside(S, P1, P2);
            boolean e_inside = isInside(E, P1, P2);

            if (s_inside && e_inside) {
                // Case 1: Both inside. Add the end point E.
                nextInput.add(E);
            } else if (s_inside && !e_inside) {
                // Case 2: Start inside, End outside. Add intersection.
                nextInput.add(getIntersection(S, E, P1, P2));
            } else if (!s_inside && e_inside) {
                // Case 3: Start outside, End inside. Add intersection *and* E.
                nextInput.add(getIntersection(S, E, P1, P2));
                nextInput.add(E);
            } else {
                // Case 4: Both outside. Add nothing.
            }
        }
        
        // The output of this clip edge becomes the input for the next
        output = nextInput;
    }


    // Convert the final ArrayList back to a Vector3[]
    Vector3[] result = new Vector3[output.size()];
    for (int i = 0; i < result.length; i += 1) {
        result[i] = output.get(i);
    }
    return result;
}

/**
 * Checks if a point P is "inside" (to the left of) the directed edge from P1 to P2.
 * Assumes a counter-clockwise (CCW) clipping polygon.
 */
 private final float EPSILON = 1e-6f; // A very small number (0.000001)
private boolean isInside(Vector3 P, Vector3 P1, Vector3 P2) {
    // ...
    return (P2.x - P1.x) * (P.y - P1.y) - (P2.y - P1.y) * (P.x - P1.x) <= EPSILON; 
}

/**
 * Calculates the intersection point of two line segments: S-E and P1-P2.
 * This is based on the 2D line intersection formula.
 * It also interpolates the Z value.
 */
private Vector3 getIntersection(Vector3 S, Vector3 E, Vector3 P1, Vector3 P2) {
    // Line 1 (Subject): S + t(E - S)
    // Line 2 (Clip):    P1 + u(P2 - P1)

    float dx_s = E.x - S.x;
    float dy_s = E.y - S.y;
    float dx_c = P2.x - P1.x;
    float dy_c = P2.y - P1.y;

    float S_P1_x = S.x - P1.x;
    float S_P1_y = S.y - P1.y;

    // Denominator of the parameter 't'
    float den = dx_s * dy_c - dy_s * dx_c;

    // Avoid division by zero (parallel lines)
    if (Math.abs(den) < 1e-6) {
        // Fallback: return the start point (or handle collinearity if needed)
        return S;
    }

    // Calculate parameter 't' for the subject line S-E
    float t = (S_P1_y * dx_c - S_P1_x * dy_c) / den;

    // Calculate intersection point (x, y, and interpolated z)
    float intersectX = S.x + t * dx_s;
    float intersectY = S.y + t * dy_s;
    float intersectZ = S.z + t * (E.z - S.z); // Interpolate Z value

    return new Vector3(intersectX, intersectY, intersectZ);
}
