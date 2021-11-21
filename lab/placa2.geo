// Gmsh project created on Wed Apr 22 20:14:41 2020
SetFactory("OpenCASCADE");
//+
Point(1) = {500, 0, 0, 1.0};
//+
Point(2) = {-500, 0, 0, 1.0};
//+
Point(3) = {0, 1500, 0, 1.0};
//+
Coherence;
//+
Line(1) = {2, 3};
//+
Line(2) = {1, 3};
//+bea
Line(3) = {1, 2};
//+
Plane Surface(2) = {2};
//+
Curve Loop(1) = {1, -2, 3};
