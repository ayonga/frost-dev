function  robot = gfxExample(arg)

% gfxExample  example of how to produce showmotion drawing instructions
% gfxExample creates a simple planar 2R robot, kinematically identical to
% that produced by planar(2), but adorned with a variety of extra graphics.
% Read the source code to see how it's done.  To view this robot, type
% showmotion(gfxExample).

% The following code creates a simple planar 2R robot, identical to planar(2).

robot.NB = 2;
robot.parent = [0,1];

robot.jtype{1} = 'r';
robot.jtype{2} = 'r';

robot.Xtree{1} = plnr( 0, [0 0]);
robot.Xtree{2} = plnr( 0, [1 0]);

robot.I{1} = mcI( 1, [0.5 0], 1/12 );
robot.I{2} = mcI( 1, [0.5 0], 1/12 );

% From here on, it's graphics

% To illustrate the use of 'vertices' and 'triangles' in making a general
% polyhedron, here is some code to make a small roof-like shape.  First, we
% define a 6x3 array containing the coordinates of the 6 vertices.  Vertex
% numbers 1, 2, 3 and 4 define the rectangular base, and vertices 5 and 6
% define the top edge.

roofV = [-0.2 -0.1 0.4; ...
	  0.1 -0.1 0.4; ...
	  0.1  0.1 0.4; ...
	 -0.2  0.1 0.4; ...
	 -0.1  0   0.5; ...
	  0    0   0.5];

% The roof consists of one rectangle, two quadrilaterals and two
% triangles.  The rectangle and quadrilaterals each require two triangles,
% so the whole roof consists of 8 triangles.  However, we are going to draw
% the roof in two colours; so we must create one list of triangles for each
% colour.  In "roofT1" below, the first two triangles make the -y facing
% quadrilateral; the next two make the +y facing quadrilateral; and the
% final two make the rectangular base.  The two triangular faces at each
% end of the roof are defined in "roofT2".  Observe that each triangle's
% vertices are listed in counter-clockwise order as seen from outside
% the roof.

roofT1 = [1 2 6; 1 6 5; 3 4 5; 3 5 6; 3 2 1; 3 1 4];
roofT2 = [2 3 6; 4 1 5];

% Note: in the default initial view, +x is pointing to the right, +z is up,
% and +y is pointing away from the camera.

% The next command creates the drawing instructions for the base.  To
% illustrate how to use 'tiles' to create rectangles facing in different
% directions, the first line creates a large floor with large tiles, and
% the next five lines create a tiled rectangular platform for the robot to
% sit on.  Specifically, lines 2 to 5 create the sides of the platform
% facing -y, +y, -x and +x, in that order, and line 6 makes the top of the
% platform.  The next line makes a box representing the robot's base.  The
% bottom of this box is a little below the top of the platform.  Finally,
% the last four lines do the following: declare the roof's vertices; make
% the quadrilateral faces of the roof; change the colour; and make the
% triangular faces.  Both the box and the quadrilateral faces of the roof
% appear in the default colour for body 0, which is brown, but tiled
% surfaces are always grey regardless of the current colour.

robot.appearance.base = ...
  { 'tiles', [-1 2; -1 1; -0.3 -0.3], 0.4, ...
    'tiles', [-0.4 0.45; -0.4 -1; -0.3 -0.15], 0.1, ...
    'tiles', [-0.4 0.45; 0.4 0.4; -0.3 -0.15], 0.1, ...
    'tiles', [-0.4 -1; -0.4 0.4; -0.3 -0.15], 0.1, ...
    'tiles', [0.45 0.45; -0.4 0.4; -0.3 -0.15], 0.1, ...
    'tiles', [-0.4 0.45; -0.4 0.4; -0.15 -0.15], 0.1, ...
    'box', [-0.2 -0.3 -0.2; 0.2 0.3 -0.07], ...
    'vertices', roofV, ...
    'triangles', roofT1, ...
    'colour', [0.45 0.2 0.35], ...
    'triangles', roofT2 };

% For body 1, we are going to use some sublists.  The following sublist
% creates a very crude sphere, with a very low facet level of 8.

crude = { 'facets', 8, ...
	  'sphere', [0.2 0 0.2], 0.1 };

% Observe that "crude" is a cell array.  Because of this, it will be
% interpreted as a sublist when it is included in the main list of drawing
% instructions; and so the scope of the 'facets' instruction includes only
% the one sphere that follows it.

% Let us also create a high-quality two-tone sphere:

posh = { 'facets', 80, ...
	 'colour', [0 0.5 0; 0.4 0.8 0.4], ...
	 'sphere', [0.4 0 0.2], 0.08 };

% Once again, this is a cell array, and so the 'facets' and 'colour'
% instructions will affect only the one sphere following it.

% The next command creates the drawing instructions for body 1.  The first
% two lines in the list create a box and a cylinder, which together make a
% sensible shape for link 1 of a planar 2R robot.  The next line is a
% sublist that begins with a 'colour' command to change the current colour
% to blue.  The next item in this sublist is the cell array in the variable
% "posh", which is therefore a subsublist in this context.  As the cell
% array in "posh" specifies both a colour (actually two colours) and a
% value for facets, it is drawn in the specified colour (two shades of
% green) and at the specified facet level of 80.  The last item in the
% sublist is the cell array in the variable "crude".  As this subsublist
% specifies a facet level but not a colour, the crude sphere will be drawn
% at the specified facet level of 8, but in the inherited current colour.
% Now, the colour declaration in "posh" is local to the subsublist it
% appears in, so the current colour for the crude sphere is blue.  The
% final two items in the main list draw a line and a sphere.  Observe that
% they are both drawn in the default colour for body 1 (red), and that the
% sphere is drawn at the default facet level of 24.

robot.appearance.body{1} = ...
    { 'box', [0 -0.07 -0.04; 1 0.07 0.04], ...
      'cyl', [0 0 -0.07; 0 0 0.07], 0.1, ...
      { 'colour', [0.1 0.3 0.6], posh, crude }, ...
      'line', [0 0 0; 0 0 0.2; 0.8 0 0.2], ...
      'sphere', [0.6 0 0.2], 0.06 };

% For anything remotely complicated, or anything that might be needed more
% than once, it is a good idea to define a function.  As an example, the
% function below makes the drawing instructions for a circle.

function  circ = circle( centre, radius, direction )
  % first make sure centre and direction are row vectors
  centre = [centre(1) centre(2) centre(3)];
  direction = [direction(1) direction(2) direction(3)];
  % now work out the plane of the circle
  Z = direction/norm(direction);
  if abs(Z(3)) < 0.5
    Y = [0 0 1];
  else
    Y = [0 1 0];
  end
  Y = Y - Z * dot(Y,Z);
  Y = Y / norm(Y);
  X = cross(Y,Z);
  % unit vectors X and Y now span the circle's plane
  % next step: make the coordinates of a unit circle
  ang = (0:100)' * 2*pi / 100;
  coords = cos(ang)*X + sin(ang)*Y;
  % now scale it to correct radius and shift it to correct position
  coords = radius*coords + ones(101,1)*centre;
  % finally, return a cell array with the drawing instructions
  circ = { 'line', coords };
end

% The next command makes the drawing instructions for body 2.  The first
% two lines in the list make a box and a cylinder, which together make a
% sensible shape for link 2 in a planar 2R robot.  The next several lines
% then make circles in various locations and colours.  The final two lines
% make a brilliant white triangle with apex at point (1.1,0,0) in link 2
% coordinates, which is relevant to the camera commands below.

robot.appearance.body{2} = ...
    { 'box', [0 -0.07 -0.04; 1 0.07 0.04], ...
      'cyl', [0 0 -0.07; 0 0 0.07], 0.1, ...
      'colour', [0 0.8 0.8], ...
      circle( [0.2 0 0], 0.15, [1 0 0] ), ...
      'colour', [0 0.75 0.8], ...
      circle( [0.25 0 0], 0.14, [1 0 0] ), ...
      'colour', [0 0.7 0.8], ...
      circle( [0.3 0 0], 0.13, [1 0 0] ), ...
      'colour', [0 0.65 0.8], ...
      circle( [0.35 0 0], 0.12, [1 0 0] ), ...
      'colour', [0 0.6 0.8], ...
      circle( [0.4 0 0], 0.11, [1 0 0] ), ...
      'colour', [0 0.55 0.8], ...
      circle( [0.45 0 0], 0.1, [1 0 0] ), ...
      'colour', [0.8 0.5 0.7], ...
      circle( [0 0 0], 0.2, [1 0 1] ), ...
      'colour', [1 1 1], ...
      'line', [1.1 0 0; 1.02 0.04 0; 1.02 -0.04 0; 1.1 0 0] };

% Showmotion supports two kinds of camera: a fixed camera and a tracking
% camera.  The latter tracks a specified point in a specified body as it
% moves.  To be more accurate, it tracks the horizontal component of the
% specified point's motion.  You get a fixed camera by default.  To get a
% tracking camera, you have to include in the model a field called camera,
% which is a structure containing various view-related fields.  To specify
% a tracking camera, you have to set .camera.body to a nonzero body number
% and .camera.trackpoint to the coordinates of the point you want to
% track.  If you call gfxExample with an argument -- any argument -- then
% it will give you a tracking camera that follows the apex of the white
% triangle on body 2.  The code that does this is below.  Try zooming in on
% the white triangle, and try watching it from different viewpoints.  (Also
% try slowing down the animation, and don't watch it too many times, or
% you'll get sea-sick.  Tracking cameras work best with mobile robots.)

if nargin > 0
  robot.camera.body = 2;
  robot.camera.trackpoint = [1.1 0 0];
end

% Other camera fields you might want to experiment with are: .direction,
% .up, .zoom and .locus.

end
