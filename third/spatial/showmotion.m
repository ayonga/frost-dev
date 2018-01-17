function  showmotion( model, t_data, q_data )

% SHOWMOTION  3D animation of a robot or other mechanical system
% showmotion(model,t_data,q_data)  presents an interactive 3D animation of
% a robot or other mechanical system.  The first argument is a model data
% structure describing the robot; the second is a vector of time values;
% and the third is an array of position variable values.  The dimension of
% q_data can be either (np)x(nt) or (np)x1x(nt), where np is the number of
% position variables required by the model and nt is the number of time
% values supplied (i.e., nt==length(t_data)).  The second option is the
% array output format of Simulink.  The second and third arguments can be
% omitted, in which case default values are supplied that exercise each
% joint in turn.  Showmotion can also be called as follows:
% showmotion(filename) -- load an animation from a matlab .mat file;
% showmotion('save',filename) -- save the current animation to a matlab
% .mat file; showmotion('about') -- print a description of the current
% animation in the matlab command window; or showmotion('about',newdata) --
% supply or modify the description data.

global ShoMoData;

  function  resizefn(source,event)	% figure resize callback
    if ishandle(ShoMoData.fig)
      ShoMoData.figrect = get( ShoMoData.fig, 'Position' );
    end
  end

  function  deletefn(source,event)	% figure delete callback
    try
      ShoMoData.figrect = get( ShoMoData.fig, 'Position' );
      if ishandle(ShoMoData.panel.fig)
	delete( ShoMoData.panel.fig );
      end
      command_summary(0);
      ShoMoData.fig = NaN;		% because Matlab recycles handles
    catch
      % ShoMoData has been cleared (e.g. by 'clear all' command)
    end
  end

firstcall = ~isstruct(ShoMoData);	% no pre-existing data structure

if nargin == 0				% check argument list
  bad_arg_list = 1;
elseif isstruct(model)
  bad_arg_list = ( ~isfield(model,'NB') || nargin == 2 );
elseif ~ischar(model)
  bad_arg_list = 1;
elseif strcmp(model,'save')
  bad_arg_list = ( nargin ~= 2 || ~ischar(t_data) );
elseif strcmp(model,'about')
  bad_arg_list = ( nargin > 2 || nargin == 2 && ~isstruct(t_data) );
else
  bad_arg_list = ( nargin ~= 1 );
end

if bad_arg_list
  msg = sprintf(['Bad argument list.  Call showmotion as follows:\n' ...
		 '  showmotion( model )\n' ...
		 '  showmotion( model, time_data, position_data )\n' ...
		 '  showmotion( filename )\n' ...
		 '  showmotion( ''save'', filename )\n' ...
		 '  showmotion( ''about'' )\n' ...
		 '  showmotion( ''about'', new_data )']);
  error( msg );
end

if ischar(model)			% save, load and about commands
  switch model
    case 'save'
      filename = t_data;
      savefile( filename );
    case 'about'
      if nargin == 2
	newdata = t_data;
	about( newdata );
      else
	about;
      end
    otherwise
      filename = model;
      loadfile( filename );
  end
  return
end

if nargin == 1
  [t_data,q_data] = default_t_q_data( model );
end

if ~isnumeric(t_data) || ~isvector(t_data) || length(t_data) < 2 || ...
      min( t_data(2:end) - t_data(1:end-1) ) < 0
  error( ['second argument must be a vector of ' ...
	  'monotonically increasing time values'] );
end

if t_data(end) <= t_data(1)
  error( 'final time value must be greater than first' );
end

if ~isnumeric(q_data)
  error( 'third argument (position data) must be numeric' );
end

if ndims(q_data) == 3 && size(q_data,2) == 1
  tmp(:,:) = q_data(:,1,:);
  q_data = tmp;
end

if ndims(q_data) ~= 2 || size(q_data,1) ~= model.NB || ...
      size(q_data,2) ~= length(t_data)
  error( ['dimensions of third argument must be (np)x(nt) or ' ...
	  '(np)x1x(nt) where np=model.NB and nt=length(t_data)'] );
end

ShoMoData.model = model;
ShoMoData.t_data = t_data;
ShoMoData.q_data = q_data;

ShoMoData.about.author = '';
ShoMoData.about.title = '';
ShoMoData.about.description = {};
ShoMoData.about.date = date;
ShoMoData.about.creator = 2;		% spatial_v2

ShoMoData.animating = 0;
ShoMoData.autorepeat = 0;
ShoMoData.vw_mode = 'normal';
speedctrl('initialize');
timectrl('initialize');
if firstcall
  ShoMoData.figrect = [];
  ShoMoData.fig = NaN;
  ShoMoData.panel = makepanel;
end

if ~ishandle(ShoMoData.fig)		% no current figure exists

  fig = figure( 'Renderer', 'OpenGL', ...
		'Color', 'k', ...
		'HandleVisibility', 'callback', ...
		'Name', 'ShowMotion', ...
		'NumberTitle', 'off', ...
		'MenuBar', 'none', ...
		'DeleteFcn', @deletefn, ...
		'ResizeFcn', @resizefn, ...
		'KeyPressFcn', @keyhandler, ...
		'WindowButtonDownFcn', {@mousehandler,'down'}, ...
		'WindowButtonUpFcn', {@mousehandler,'up'}, ...
		'WindowButtonMotionFcn', {@mousehandler,'move'}, ...
		'WindowScrollWheelFcn', {@mousehandler,'scroll'} );

  if firstcall
    ShoMoData.figrect = get( fig, 'Position' );
  else
    set( fig, 'Position', ShoMoData.figrect );
  end
  ShoMoData.fig = fig;
  newfigure = 1;

else					% reuse current figure
  fig = ShoMoData.fig;
  delete( ShoMoData.ax );		% but delete its axes
  newfigure = 0;
end

ax = axes( 'Parent', fig, ...
	   'Position', [0 0 1 1], ...
	   'Visible', 'off', ...
	   'DataAspectRatioMode', 'manual', ...
	   'PlotBoxAspectRatioMode', 'manual' );
ShoMoData.ax = ax;

ShoMoData.ball = crystalball( ax );

ShoMoData.handles = makedrawing( model, ax );
ShoMoData.camera = makecamera( model );
ShoMoData.lights = makelights( ShoMoData.camera, ax );

reposition;
viewreset;
makemenu;

if newfigure
  showpanel;
end
updatepanel;

drawnow;
end					% because there are nested functions


%----------


%{
SHOWMOTION  --  a few words of explanation
----------

This is the source code for the 3D animator/viewer ShowMotion, which is part
of the software package spatial_v2.  It was developed as a collection of
separate files, which were concatenated to make this single file.  Comments of
the form %---------- mark the boundaries between the files.  Because a few
files contain nested functions, it is necessary that all files finish their
functions with 'end'.  The next file after this one is the shell script that
assembles everything into a single file.  You can use it as a table of
contents.

The functions communicate via a single global variable called ShoMoData, which
is explained below.  This strategy is necessitated by the decision to develop
ShowMotion in separate files and concatenate them only as the final step.  All
vectors and 1D arrays in this data structure are row vectors, except t_data,
which is free to be either a row or a column vector.

ShoMoData:
  model		model data structure for this animation
  t_data	vector of time values for this animation
  q_data	2D array of position variable data, one row for each joint
  		variable in the model, and one column for each time value
  about		data structure containing description (meta-)data from a
  		loaded animation file, or data to store with the current
		animation when it is saved
    author	string containing author(s) name(s)
    title	string containing animation's title
    description cell array of strings, one per line, providing a plain-text
    		description of the animation
    date	creation-date string (date stamp issued when an animation is
    		saved to a file)
    creator	version number of the software that created the file (=2)
    playable	list of versions capable of playing it (=2)
  animating	boolean: true when animation in progress
  autorepeat	boolean: true when autorepeat (infinite loop) enabled
  vw_mode	string used by mousehandler() to track current viewing mode,
		values are 'normal', 'rotate' and 'pan'
  speed		data structure containing speed-related quantities
    scale	array defining the nonlinear scale on the speed slider
    range	defines the size and value range of the speed slider
    		  (a slider with a range of N produces integers in the range
		  0..N and has a slot N+3 pixels wide with a working range of
		  N+1 pixels)
    unity	index of the element in .scale having unit value
    ix		index into .scale identifying current speed magnitude
    sgn		defines the sign of the speed, values: +/-1
    speed	actual speed, defined by .speed = .sgn * .scale(.ix)
    sliderpos	position of the speed slider's pointer, 0<=.sliderpos<=.range
    displaystring  string containing the numeric value of .speed
  tmin		minimum time, a copy of .t_data(1)
  tmax		maximum time, a copy of .t_data(end)
  tview		time of the current view in the main window
  time		data structure containing time-related quantities
    coarseRange	(=400) defines the size and range of the coarse time slider
    fineRange	(=100) defines the size and range of the fine time slider
    cSliderPos	visible position of the coarse slider's pointer
    fSliderPos	visible position of the fine slider's pointer
  figrect	array containing the figure rectangle: [x y wid ht]
  fig		handle of the main figure, or NaN if figure does not exist
  panel		structure relating to the control panel -- see below
  ax		handle of the main figure's axes
  ball		handle of the crystal ball, visible when .vw_mode=='rotate'
  handles	handles of the moving bodies: .handles(i) is the handle of an
		hgtransform graphics object, and manipulating its matrix
		alters the position of body i; see reposition()
  camera	structure containing camera-related quantities
    trackbody	body number of body to track, or zero for a fixed camera
    trackpoint	point to be tracked in moving body (3D vector expressed in
		body coordinates)
    direction	defines initial viewing direction of camera (3D vector
		expressed in scene coords pointing from scene to camera)
    up		defines initial camera 'up' vector (3D vector in scene coords)
    zoom	zoom factor relative to default
    locus	2D vector in normalized window coordinates specifying where in
		the window the trackpoint should appear
    oldtrackpos	 previous location of .trackpoint in scene coordinates
  lights	structure relating to lighting
    overhead	handle of the overhead light
    camera	handle of the camera headlight
    overheadPower  intensity of overhead light (range 0..1)
    cameraPower	 intensity of camera headlight (range 0..1)
  view		structure defining camera viewing parameters
    on_hold	boolean: true if camera has not been updated (update is
    		immediate if not animating, batched if animating)
    angle	camera viewing angle, set to 25 degrees
    upvec	camera up vector    }
    focus	camera target point } all in scene coordinates
    campos	camera position     }
  treal		tracks the passage of real time since the start of the current
  		animation, used by animate() to get the speed right

ShoMoData.panel:
  red		}
  orange	} RGB values defining the colours used to draw the control
  green		} panel
  grey		}
  width		width of control panel figure (=427)
  height	height of control panel figure (=80)
  xy		data structure containing the x-y coordinates of everything
		that appears in the control panel (i.e., it defines the
		control panel's layout)
  figpos	position of control panel figure on screen
  fig		control panel figure handle, or NaN if figure does not exist
  repeat_off	icon showing that auto-repeat is switched off
  repeat_on	icon showing that auto-repeat is switched on
  forward	icon showing that speed is positive (animations play forward)
  reverse	icon showing that speed is negative (animations play backwards)
  ax		handle of control panel's axes
  playing	boolean: true if the 'play' triangle is glowing orange
  play		handle of the play triangle
  repeating	boolean: true if the auto-repeat button is displaying the icon
  		.repeat_on
  repeat	handle of the image displaying the auto-repeat on/off icon
  timeDisplay	handle of the string displaying the current time (.tview)
  updated	time when .timeDisplay was last updated, used by updatepanel()
  		to limit the frequency at which .timeDisplay is updated
  coarseSlider	handle of coarse time slider's pointer
  fineSlider	handle of fine time slider's pointer
  goingfwd	boolean: true if the direction button is displaying the icon
		.forward
  direction	handle of the image displaying the forward/reverse icon
  speedSlider	handle of the speed slider's pointer
  speedDisplay	handle of the string displaying the current speed
  drag		structure used when sliders are being dragged
    pos		unclipped slider position calculated from .x
    mode	string identifying which slider is being dragged, values are
		'speed', 'fine', 'coarse'
    x		most recent x coordinate of cursor (pixels)

Overall, ShowMotion works by storing its arguments in ShoMoData, initializing
various other fields of ShoMoData, and creating one or two figures: a main
figure, showing 3D graphics, and (optionally) a control panel with sliders,
buttons and numeric displays.  The latter is done the hard way: with basic
handle graphics and low-level code in callback functions.  This is partly
because Matlab's high-level user-interface functions are not trustworthy
enough, and partly because they are not well suited to applications where the
user interface itself is being animated in real time.  ShowMotion can also
display a command-summary window if you ask for help, but that is just static
text.

Calling showmotion(model,...) or showmotion(filename) starts a new ShowMotion
session, terminating the current session if any.  Other ways to terminate the
current session are: via ShowMotion's pop-up menu (right mouse) in the main
window, closing the main window, or exiting Matlab.  When ShowMotion starts a
new session, it tries to re-use the existing windows, or, if they have been
deleted, to create new windows in the same places.  This is why ShowMotion
tries to keep track of where its windows are.

After the initial setup phase, everything is done by callback routines, and
every action except animation is essentially instantaneous.  Animation itself
is implemented as a busy loop in which the processing of the next frame begins
as soon as the previous one is completed.  During animation, all ShowMotion
keyboard, mouse and control-panel commands are still operational and have
practically instantaneous effect.  However, the main Matlab command-line
window will be unresponsive.  Animation uses the Matlab functions tic and toc
to measure the passage of real time during the animation, to make sure it
proceeds at the correct speed.  If the time taken to draw a frame varies
significantly from one frame to the next then you will see a degree of visual
jitter in the displayed motion.

To allow smooth mouse-based view rotation and panning during animation, it is
necessary to defer and accumulate the incremental changes from each drag
event, rather than update the camera immediately with each event.  This policy
is implemented via the function viewupdate() and ShoMoData.view.

BUGS:

1. Matlab does not play nicely with Ubuntu window managers, and perhaps not
   with other window managers either.  Both the position and size of the
   window you get can be different from what you asked for, and the reported
   position and size (from get()) can differ from what is on the screen.
   Worse, the place where you have to click in order to hit a graphical object
   can be several pixels above where that object appears on the screen.  This
   can adversely affect the usability of the control panel.  I have no cure
   for this problem.  However, as it is intermittent in nature, a last-resort
   remedy is to alert the user to the problem (in the command summary window's
   tips) and recommend deleting the offending window and creating a new one,
   which is easily done using the keyboard command 'p'.

2. Issuing a 'clear all' or 'clear global' Matlab command will clear
   ShoMoData.  If this is done while showmotion windows exist, these windows
   become broken, and must be deleted manually.  The callback routines check
   for this possibility, with the effect that the main window will disappear
   as soon as you move the cursor over it, and the control panel and command
   summary windows will disappear if you press any key while they have the
   keyboard focus or click on any clickable object.

3. Certain viewing parameters cause the scene to vanish (i.e., the main window
   goes black).  This bug is repeatable, and is probably due to Matlab.  Only
   a very small percentage of viewing parameters cause this problem, and their
   exact values probably depend on the contents of the scene.  If this happens
   to you, then you simply have to move the camera a bit.

4. Rendering of models with a lot of bodies is slower than it should be.  For
   example, rendering a 100-link robot with each body drawn as a box is
   significantly slower than rendering a 10-link robot with each body drawn as
   10 boxes.  Again, this seems to be attributable to Matlab.
%}


%----------


%{
echo 'concatenating all source files to make showmotion.all'
echo -e '\n\n%----------\n\n' > x
echo '%{' > y
echo '%}' > z
cat showmotion.m   x y comments.txt z  x y assemble z       x > a0
cat about.m        x adjustball.m      x adjustlighting.m   x > a1
cat animate.m      x bounds.m          x box.m              x > a2
cat cameraxes.m    x command_summary.m x crystalball.m      x > a3
cat cylinder.m     x defaultcolour.m   x default_t_q_data.m x > a4
cat floortiles.m   x interpolate.m     x keyhandler.m       x > a5
cat loadfile.m     x lyne.m            x makecamera.m       x > a6
cat makedrawing.m  x makelights.m      x makemenu.m         x > a7
cat makepanel.m    x mousehandler.m    x mousepos.m         x > a8
cat mouseray.m     x panelhandler.m    x reposition.m       x > a9
cat savefile.m     x showpanel.m       x speedctrl.m        x > aa
cat sphere.m       x timectrl.m        x triangles.m        x > ab
cat updatepanel.m  x viewkeypan.m      x viewmousepan.m     x > ac
cat viewmouserot.m x viewpan.m         x viewrefocus.m      x > ad
cat viewreset.m    x viewrotate.m      x viewtrack.m        x > ae
cat viewupdate.m   x viewzoom.m                               > af

cat a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af > showmotion.all
rm a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af x y z
%}


%----------


function  about( newdata )

% about  print/alter author/title/description data
% about(newdata)  prints or alters the author, title and description data
% stored with the current animation.  If no argument is supplied then the
% current stored data is printed to standard output (i.e., the Matlab
% command window).  If an argument is supplied then it must be a structure
% containing one or more of the following fields: .author, .title and
% .description.  All three are strings, but the string in .description is
% interpreted as the name (including extension) of a plain text file
% containing the description text.  For each field supplied, the new data
% replaces the old.  To remove the current value, set the new value to ''
% (the empty string).  This works for .description too; i.e.,
% .description='' is treated as a special case meaning "remove the current
% description data".  Note: when description data is printed, it is
% automatically wrapped at the 80th column.

  global  ShoMoData;
  
  if ~isstruct(ShoMoData)
    error('There is no animation to describe');
  end
  
  if nargin == 1			% modify current data
    
    % error checking -- is the argument OK?
    
    if ~isstruct(newdata)
      error('Argument must be a structure');
    else
      ok = 0;
      if isfield(newdata,'author')
	if ~ischar(newdata.author)
	  error('Author field must be a string');
        end
        ok = 1;
      end
      if isfield(newdata,'title')
	if ~ischar(newdata.title)
	  error('Title field must be a string');
        end
        ok = 1;
      end
      if isfield(newdata,'description')
	if ~ischar(newdata.description)
	  error('Description field must be a string');
        end
        ok = 1;
      end
      if ~ok
	error(['Argument must contain at least one field ''author'','...
	       ' ''title'' or ''description''']);
      end
    end
    
    % everything OK, so make the changes
    
    if isfield( newdata, 'author' )
      ShoMoData.about.author = newdata.author;
    end
    
    if isfield( newdata, 'title' )
      ShoMoData.about.title = newdata.title;
    end
    
    if isfield( newdata, 'description' )
      if length(newdata.description) == 0
	ShoMoData.about.description = {};
      else
	ShoMoData.about.description = read_desc( newdata.description );
      end
    end
    
  else					% print current data
    
    if length(ShoMoData.about.title) > 0
      fprintf( 1, 'Title:   %s\n', ShoMoData.about.title );
    else
      fprintf( 1, 'Title:   not specified\n' );
    end
    
    if length(ShoMoData.about.author) > 0
      fprintf( 1, 'Author:  %s\n', ShoMoData.about.author );
    else
      fprintf( 1, 'Author:  not specified\n' );
    end
    
    fprintf( 1, 'Date:    %s\n', ShoMoData.about.date );
    fprintf( 1, 'creator: spatial_v%g\n\n', ShoMoData.about.creator );
    
    if length(ShoMoData.about.description) > 0
      fprintf( 1, 'Description:\n\n' );
      desc = ShoMoData.about.description;
      for i = 1:length(desc)
	print_line( desc{i} );
      end
    else
      fprintf( 1, 'Description:  not specified\n' );
    end
    
  end
end



function  desc = read_desc( filename )
  
% read a description (a cell array of strings) from a text file
  
  [fid, message] = fopen( filename );

  if length(message) > 0
    error(['Unable to read file ',filename,': ',message]);
  end

  desc = {};
  i = 1;
  while 1
    txt = fgetl(fid);
    if ~ischar(txt)			% end of file
      break
    end
    desc{i} = deblank(txt);  		% remove trailing white space
    i=i+1;
  end

  fclose(fid);
end


function  print_line( txt )
  
% print a line, auto-wrapping at the 80th column if necessary
  
  maxlen = 80;
  
  while 1
    spc = strfind( txt, ' ' );
    if length(spc) == 0 || length(txt) <= maxlen
      fprintf( 1, '%s\n', txt );
      return
    elseif spc(1) >= maxlen
      fprintf( 1, '%s\n', txt(1:spc(1)-1) );
      txt = strtrim(txt(spc(1)+1:end));
    else
      j = sum( spc < maxlen );
      fprintf( 1, '%s\n', deblank(txt(1:spc(j)-1)) );
      txt = strtrim(txt(spc(j)+1:end));
    end
  end
end


%----------


function  adjustball( on )

% ADJUSTBALL  adjust position, radius and visibility of crystal ball
% adjustball(on)  alters the position and radius of the ShowMotion crystal
% ball so that it is centred on the camera's current target and its radius
% is such that it occupies 80% (linearly) of the current view.  If an
% argument is supplied then this function makes the ball visible (on==1) or
% invisible (on==0), otherwise it leaves the visibility unaltered.

global ShoMoData;

if nargin == 1
  if on
    set( ShoMoData.ball, 'Visible', 'on' );
  else
    set( ShoMoData.ball, 'Visible', 'off' );
  end
else
  on = strcmp( 'on', get(ShoMoData.ball,'Visible') );
end

if on
  vw = ShoMoData.view;
  d = norm( vw.campos - vw.focus );
  phi = atan(0.8*tan(vw.angle/2));
  r = d * sin(phi);			% radius that will fill 80% of view
  M = [ r*eye(3), vw.focus'; 0 0 0 1 ];
  set( ShoMoData.ball, 'Matrix', M );
end
end


%----------


function  adjustlighting( cam, sun )

% ADJUSTLIGHTING  adjust lights in a showmotion scene
% adjustlighting(cam,sun) allows one to adjust the intensity of the camera
% headlight and the overhead light (sunshine).  Arguments take values of
% +1, -1 or 0, meaning more, less or no change.  If this function is called
% with no arguments, then it updates the position of the camera headlight.
% (This must be done every time the camera is moved.)

global ShoMoData;

N = 12;					% number of intensity levels
CAM_AZ = 10;				% camera headlight relative azimuth
CAM_EL = 20;				% and elevation in degrees

if nargin == 0
  camlight( ShoMoData.lights.camera, CAM_AZ, CAM_EL );
else
  if cam ~= 0
    p = ShoMoData.lights.cameraPower;
    if cam > 0
      if p == 0
	set( ShoMoData.lights.camera, 'Visible', 'on' );
      end
      p = min( 1, p+1/N );
    else
      p = max( 0, p-1/N );
      if p < 1e-6/N
	set( ShoMoData.lights.camera, 'Visible', 'off' );
	p = 0;
      end
    end
    ShoMoData.lights.cameraPower = p;
    set( ShoMoData.lights.camera, 'Color', p*[1 1 1] );
  end
  if sun ~= 0
    p = ShoMoData.lights.overheadPower;
    if sun > 0
      p = min( 1, p+1/N );
    else
      p = max( 1/N, p-1/N );
    end
    ShoMoData.lights.overheadPower = p;
    set( ShoMoData.lights.overhead, 'Color', p*[1 1 1] );
  end
end
end


%----------


function  animate

% ANIMATE  perform a ShowMotion animation
% animate commences or resumes a ShowMotion animation, exiting only when
% the animation is complete or has been stopped by some other event.
% Animation is implemented as a free-running busy loop in which the drawing
% of the next frame starts as soon as the current one is finished.  Thus,
% the frame rate is as fast as the computer can go.  animate uses the
% Matlab functions tic and toc to calculate the time interval between
% frames; so you should refrain from using these functions in other code
% while an animation is in progress.

global ShoMoData;

tic;					% .treal tracks elapsed real time
ShoMoData.treal = toc;			% since start of animation

% perform automatic rewind if required

if ShoMoData.speed.speed > 0 && ShoMoData.tview >= ShoMoData.tmax
  timectrl( 'set', ShoMoData.tmin );
elseif ShoMoData.speed.speed < 0 && ShoMoData.tview <= ShoMoData.tmin
  timectrl( 'set', ShoMoData.tmax );
end

ShoMoData.animating = 1;		% now start animation
reposition;
viewtrack;
viewupdate;
updatepanel;
drawnow;

while ishandle(ShoMoData.fig) && ShoMoData.animating
  treal = toc;
  tview = ShoMoData.tview + ShoMoData.speed.speed * (treal-ShoMoData.treal);
  if ShoMoData.speed.speed > 0
    if tview >= ShoMoData.tmax
      if ShoMoData.autorepeat
	tview = tview - (ShoMoData.tmax - ShoMoData.tmin);
      else
	tview = ShoMoData.tmax;
	ShoMoData.animating = 0;
      end
    end
  elseif ShoMoData.speed.speed < 0
    if tview <= ShoMoData.tmin
      if ShoMoData.autorepeat
	tview = tview + (ShoMoData.tmax - ShoMoData.tmin);
      else
	tview = ShoMoData.tmin;
	ShoMoData.animating = 0;
      end
    end
  end
  ShoMoData.treal = treal;
  timectrl('set',tview);
  reposition;
  viewtrack;
  viewupdate;
  updatepanel;
  drawnow;
end
end


%----------


function  [X,Y,Z] = bounds( h, T )

% BOUNDS  calculate bounding box for all moving bodies
% [X,Y,Z]=bounds  calculates the coordinates of a bounding box (in scene
% coordinates) containing all of the moving bodies.  Each returned value is
% a low/high pair.

% Note:  This function privately calls itself recursively with arguments h:
% a handle and T: a 4x4 homogeneous coordinate transform from local to
% scene coordinates (for column vectors); but the main call must have no
% arguments.

% Note:  The drawing instructions for a moving body must consist of patch,
% line, hggroup and hgtransform objects only.

  function  mm = minmax( vec )
    mm = [ min(vec), max(vec) ];
  end

global ShoMoData;

if nargin == 0				% main call
  
  X=[]; Y=[]; Z=[];

  for h = ShoMoData.handles
    [x,y,z] = bounds( h, eye(4) );
    X = minmax( [x,X] );
    Y = minmax( [y,Y] );
    Z = minmax( [z,Z] );
  end

  if length(X) == 0
    error('no moving body has drawing instructions');
  end

else					% internal (private) recursive call

  type = get( h, 'Type' );

  switch type
    case { 'patch', 'line' }
      if strcmp( type, 'patch' )
	vertices = get( h, 'Vertices' );
      else
	vx = get( h, 'XData' );
	vy = get( h, 'YData' );
	vz = get( h, 'ZData' );
	vertices = [vx' vy' vz'];
      end
      vertices(:,4) = 1;
      vertices = vertices * T';
      X = minmax(vertices(:,1));
      Y = minmax(vertices(:,2));
      Z = minmax(vertices(:,3));

    case { 'hggroup', 'hgtransform' }
      if strcmp( type, 'hgtransform' )
	t = get( h, 'Matrix' );
	T = T * t;
      end
      X=[]; Y=[]; Z=[];
      c = get( h, 'Children' );
      for h = c'
	[x,y,z] = bounds( h, T );
	X = minmax( [x,X] );
	Y = minmax( [y,Y] );
	Z = minmax( [z,Z] );
      end
      
    otherwise
      error(['drawing instructions must consist of patch, line, hggroup' ...
	     ' and hgtransform objects only']);
  end
end
end	% of main function (because there is a nested function)


%----------


function  h = box( parent, coords, colour )

% BOX  make a patch surface in the shape of a box
% h=box(parent,coords,colour) creates a box having the specified parent,
% coordinates and colour, and returns its handle.  Coords is a 2x3 matrix
% containing  any two diametrically opposite vertices of the box.  The box
% itself is aligned with the coordinate axes.  Colour is an RGB colour
% vector.

if any(coords(1,:)==coords(2,:))
  error('a box must have positive extent in all 3 dimensions');
end

x0 = min(coords(:,1));  x1 = max(coords(:,1));
y0 = min(coords(:,2));  y1 = max(coords(:,2));
z0 = min(coords(:,3));  z1 = max(coords(:,3));

vertices = [ x0 y0 z0;  x1 y0 z0;  x1 y1 z0;  x0 y1 z0; ...
	     x0 y0 z1;  x1 y0 z1;  x1 y1 z1;  x0 y1 z1 ];

faces = [ 5 6 7 8;  6 5 1 2;  7 6 2 3;  8 7 3 4;  5 8 4 1;  4 3 2 1 ];

facenormals = [ 0 0 1;	0 -1 0;  1 0 0;  0 1 0;  -1 0 0;  0 0 -1 ];

h = hggroup( 'Parent', parent );

for i = 1:6
  patch( 'Parent', h, ...
	 'Vertices', vertices(faces(i,:),:), ...
	 'VertexNormals', ones(4,1)*facenormals(i,:), ...
	 'Faces', [1 2 3 4], ...
	 'FaceColor', colour, ...
	 'EdgeColor', 'none', ...
	 'FaceLighting', 'gouraud', ...
	 'BackFaceLighting', 'unlit' );
end
end


%----------


function  [X,Y,Z] = cameraxes

% CAMERAXES  returns the axes of the camera coordinate system
% [X,Y,Z]=cameraxes  returns the scene coordinates of the three unit
% vectors that define the camera coordinate system.  Z points directly
% towards the camera, X points right, and Y points up.  All three are
% column vectors.  The matrix E = [X Y Z] is the coordinate transform from
% camera to scene coordinates.

global ShoMoData;

vw = ShoMoData.view;

camdir = vw.campos - vw.focus;
Z = camdir / norm(camdir);
Y = vw.upvec - Z * dot(Z,vw.upvec);
Y = Y / norm(Y);
X = cross( Y, Z );

X=X'; Y=Y'; Z=Z';			% return column vectors

end


%----------


function  command_summary(on)

% COMMAND_SUMMARY  display a ShowMotion command summary
% command_summary(on)  displays (on==1) or deletes (on==0) a summary of
% ShowMotion commands in a separate window.

persistent fig;
persistent figxy;

  function  deletefn(source,event)	% window delete callback function
    pos = get( source, 'Position' );
    figxy = pos(1:2);			% remember where the window was
    fig = [];				% indicate that it has been deleted
  end

if on == 0				% delete request
  if length(fig) ~= 0			% figure exists
    delete( fig );			% so delete it
  end
  return
end

if length(fig) ~= 0			% figure exists
  figure(fig);				% so just raise it
  return
end

% the code from here on is concerned with creating a new command summary
% window

headings = {...
    'Keyboard Commands', ...
    'Mouse Commands (main window)', ...
    'Control Panel Commands', ...
    'Tips' };

content{1}{1} = {...
    'space', ...
    '0 (zero)', ...
    'r', ...
    'p', ...
    'h, ?', ...
    'comma, dot, slash', ...
    '1', ...
    'arrow keys', ...
    'shift-arrow keys', ...
    'ctrl-arrow keys', ...
    'z, Z', ...
    'i', ...
    'l, L, o, O', ...
    'n, m, N, M, ctrl-N/M' };

content{1}{2} = { ...
    'play/pause toggle', ...
    'pause (if playing), rewind (if paused)', ...
    'auto-repeat on/off', ...
    'display/hide control panel (see tip 1)', ...
    'show command summary (this window)', ...
    'adjust animation speed and direction', ...
    'reset animation speed to +1', ...
    'pan', ...
    'rotate view', ...
    'rotate, zoom', ...
    'zoom', ...
    'restore initial view', ...
    'adjust camera & overhead light intensity', ...
    'adjust time in big/medium/small steps' };

content{2}{1} = { ...
    'left button', ...
    'shift-left button', ...
    'middle button', ...
    'left & right buttons', ...
    'scroll wheel', ...
    'right button' };

content{2}{2} = { ...
    'rotate (with crystal ball - see tip 2)', ...
    'pan', ...
    'pan (UNIX)', ...
    'pan (Windows)', ...
    'zoom, refocus (see tip 3)', ...
    'menu' };

content{3}{1} = { ...
    'triangle', ...
    'square', ...
    'loop icon', ...
    'help', ...
    'two-arrow icon', ...
    'speed slider', ...
    'time slider', ...
    'fine time slider' };

content{3}{2} = { ...
    'play/pause toggle', ...
    'pause (if playing), rewind (if paused)', ...
    'auto-repeat on/off', ...
    'display command summary (this window)', ...
    'reverse animation direction', ...
    'adjust animation speed', ...
    'coarse time adjustment', ...
    'fine time adjustment' };

content{4}{1} = { ...
    '1.', ' ', '2.', ' ', '3.' };

content{4}{2} = { ...
    'Control panel bug: clickable items sometimes appear below', ...
    'where they should be.  Aim high, or hide and redisplay.', ...
    'When the cursor is over the crystal ball, it rotates as if you', ...
    'were moving it with your finger (=cursor).', ...
    'While the left button is depressed, the scroll wheel moves', ...
    'the crystal ball towards & away from the camera.  Try it,', ...
    'and watch the intersections.' };

% Algorithm:  We first create a window having default size and position,
% and place all the strings into it at a nominal position near the bottom
% left corner.  Once the strings are there, we can find out their extent,
% and hence work out the correct window size and correct layout within it.
% The window is then resized and repositioned, and the strings are moved to
% their correct final positions.

fig = figure( 'Visible', 'off', ...
	      'Resize', 'off', ...
	      'HandleVisibility', 'callback', ...
	      'Name', 'ShowMotion Command Summary', ...
	      'NumberTitle', 'off', ...
	      'MenuBar', 'none', ...
	      'KeyPressFcn', @keyhandler, ...
	      'DeleteFcn', @deletefn );

figpos = get( fig, 'Position' );

ax = axes( 'Parent', fig, ...
	   'Position', [0 0 1 1], ...
	   'Visible', 'off', ...
	   'XLim', [0.5 figpos(3)+0.5], ...
	   'YLim', [0.5 figpos(4)+0.5] );	% data coords == pixel coords

for i = 1:4
  handle(i,1) = text( 'Parent', ax, ...
		      'Position', [10 10], ...
		      'String', headings{i}, ...
		      'HorizontalAlignment', 'left', ...
		      'VerticalAlignment', 'bottom', ...
		      'FontWeight', 'bold' );
  handle(i,2) = text( 'Parent', ax, ...
		      'Position', [10 10], ...
		      'String', content{i}{1}, ...
		      'HorizontalAlignment', 'left', ...
		      'VerticalAlignment', 'bottom' );
  handle(i,3) = text( 'Parent', ax, ...
		      'Position', [10 10], ...
		      'String', content{i}{2}, ...
		      'HorizontalAlignment', 'left', ...
		      'VerticalAlignment', 'bottom' );
  for j = 1:3
    extent = get( handle(i,j), 'Extent' );
    width(i,j) = extent(3);
    height(i,j) = extent(4);
  end
end

width(1,2) = width(1,2) - 10;		% special adjustment for kbd cmd list
width(end,2) = width(end,2) - 10;	% special adjustment for tips list
totheight = sum(height(:,1)) + sum(max(height(:,2),height(:,3)));
totwidth = max(width(:,2)+width(:,3));

if length(figxy) == 0			% no known previous position
  figxy = [100 10];			% so use this default value
end
figpos = [figxy totwidth+36 totheight+25];

set( fig, 'Position', figpos );
set( ax, 'XLim', [0.5 figpos(3)+0.5], 'YLim', [0.5 figpos(4)+0.5] );

y = 0;
for i = 4:-1:1
  y = y + max(height(i,2),height(i,3));
  set( handle(i,2), 'Position', [10 y], 'VerticalAlignment', 'top' );
  x = 30 + width(i,2);
  set( handle(i,3), 'Position', [x y], 'VerticalAlignment', 'top' );
  y = y + height(i,1);
  set( handle(i,1), 'Position', [10 y], 'VerticalAlignment', 'top' );
  y = y + 5;
end

set( fig, 'Visible', 'on' );

end					% because there is a nested function


%----------


function  h = crystalball( parent )

% CRYSTALBALL  make a transparent sphere to facilitate rotation via mouse
% h=crystalball(parent)  creates a transparent sphere that is used to guide
% the rotation of showmotion scenes via the mouse.

h = hgtransform( 'Parent', parent );

s = sphere( h, [0 0 0], 1, [0.7 0.7 0.7], 48 );

sc = get( s, 'Children' );		% handles of the 8 patches that
                                        % make the sphere
set( sc, 'FaceAlpha', 0.35 );
set( sc, 'SpecularExponent', 4 );
set( sc, 'SpecularStrength', 0.4 );
set( h, 'Visible', 'off' );

end


%----------


function  h = cylinder( parent, spine, radius, colour, facets )

% CYLINDER  make a patch surface in the shape of a cylinder
% h=cylinder(parent,spine,radius,colour,facets)  creates a cylinder having
% the specified parent, geometry and colour, and returns its handle.  Spine
% is a 2x3 matrix whose rows specify the centre points of the two ends of
% the cylinder; colour is an RGB colour vector; and facets specifies the
% number of faces to be used in approximating the cylinder.  If omitted,
% facets defaults to 24.

% Implementation Notes:
% 1. I found that using quadrilaterals for the cylinder surface resulted in
%    incorrect rendering of one of the end faces in lit OpenGL, so I used
%    triangles for everything.
% 2. I put a vertex at the centre of each end face to avoid asymmetrical
%    lighting artifacts.

if nargin < 5
  facets = 24;
end
N = facets;

% Step 1: vertices and surface normals for a canonical cylinder
% (radius = height = 1, base at origin)

x = cos(2*pi*(0:N-1)'/N);
y = sin(2*pi*(0:N-1)'/N);
z1 = ones(N,1);
z0 = zeros(N,1);

topvertices = [ 0 0 1;   x y z1 ];
botvertices = [ 0 0 0;   x y z0 ];
cylvertices = [ x y z1;  x y z0 ];

topnormals = [ 0 0 1;   z0 z0 z1 ];
botnormals = [ 0 0 -1;  z0 z0 -z1 ];
cylnormals = [ x y z0;  x y z0 ];

% Step 2: scale, rotate and shift the vertices, and rotate the normals, to
% their correct values

% First, identify which end of the spine has the smaller z coordinate.  By
% choosing this end as the base, we ensure that the rotation angle will be
% <= pi/2.

if spine(2,3) >= spine(1,3)
  base = spine(1,:);
  dir = spine(2,:) - base;		% vector along cylinder axis
else
  base = spine(2,:);
  dir = spine(1,:) - base;
end

height = norm(dir);

if height == 0
  error('the two end points of a cylinder must be different');
end

scale = diag([radius,radius,height]);

dir = dir / height;			% find a rotation matrix that will
d = norm(dir(1:2));			% rotate the z axis into the
if d == 0				% correct direction
  rotate = eye(3);
else
  rotate = [ -dir(1)*dir(3)/d  dir(2)/d  dir(1); ...
	     -dir(2)*dir(3)/d -dir(1)/d  dir(2); ...
	      d                0         dir(3) ];
end

rotate = rotate';			% to operate on row vectors

shift1 = ones(N+1,1) * base;
shift2 = ones(2*N,1) * base;

topvertices = topvertices * scale * rotate + shift1;
botvertices = botvertices * scale * rotate + shift1;
cylvertices = cylvertices * scale * rotate + shift2;

topnormals = topnormals * rotate;
botnormals = botnormals * rotate;
cylnormals = cylnormals * rotate;

% Step 3: define the faces

for i = 1:N-1
  topfaces(i,:) = [ 1 i+1 i+2 ];
  botfaces(i,:) = [ 1 i+2 i+1 ];
  cylfaces(i,:) = [ i+1 i N+i+1 ];
  cylfaces(N+i,:) = [ i N+i N+i+1 ];
end
topfaces(N,:) = [ 1 N+1 2 ];
botfaces(N,:) = [ 1 2 N+1 ];
cylfaces(N,:) = [ 1 N N+1 ];
cylfaces(2*N,:) = [ N 2*N N+1 ];

% Step 4: create the cylinder as three surface patches in a group

h = hggroup( 'Parent', parent );

patch( 'Parent', h, ...
       'Vertices', topvertices, ...
       'VertexNormals', topnormals, ...
       'Faces', topfaces, ...
       'FaceColor', colour, ...
       'EdgeColor', 'none', ...
       'FaceLighting', 'gouraud', ...
       'BackFaceLighting', 'unlit' );

patch( 'Parent', h, ...
       'Vertices', botvertices, ...
       'VertexNormals', botnormals, ...
       'Faces', botfaces, ...
       'FaceColor', colour, ...
       'EdgeColor', 'none', ...
       'FaceLighting', 'gouraud', ...
       'BackFaceLighting', 'unlit' );

patch( 'Parent', h, ...
       'Vertices', cylvertices, ...
       'VertexNormals', cylnormals, ...
       'Faces', cylfaces, ...
       'FaceColor', colour, ...
       'EdgeColor', 'none', ...
       'FaceLighting', 'gouraud', ...
       'BackFaceLighting', 'unlit' );
end


%----------


function colour = defaultcolour( bodynum )

% DEFAULTCOLOUR  default ShowMotion body colours
% colour=defaultcolour(bodynum)  returns the default body colour (RGB
% vector) for a given body number

colours = [ 0.8  0.1  0.1; ...
	    0.8  0.4  0.1; ...
	    0.8  0.7  0.1; ...
	    0.25 0.6  0.0; ...
	    0.0  0.38 0.25; ...
	    0.4  0.65 0.8; ...
	    0.1  0.3  0.75; ...
	    0.5  0.1  0.8; ...
	    0.8  0.45 0.7; ...
	    0.8  0.1  0.6; ...
	    0.6  0.6  0.55; ...
	    0.4  0.3  0.2 ];

colour = colours( mod(bodynum-1,size(colours,1)) + 1, : );

end


%----------


function  [t_data,q_data] = default_t_q_data( model )

% default_t_q_data  default values for t_data and q_data
% default_t_q_data(model)  returns default values for the arguments t_data
% and q_data in showmotion.  The default values exercise each joint in the
% given model by ramping each joint variable, one at a time, from 0 to 1
% and back to 0, at a rate of one variable per second.

t_data = 0:0.5:model.NB;

q_data = zeros( model.NB, 2*model.NB+1 );

q_data(:,2*(1:model.NB)) = eye(model.NB);

end


%----------


function  h = floortiles( parent, X, Y, Z, tilesize, colour )

% FLOORTILES  make a patch surface looking like a tiled floor
% h=floortiles(parent,X,Y,Z,tilesize,colour) creates a rectangular surface
% composed of square tiles in a chequer-board pattern.  X, Y and Z must be
% either three 2-element vectors or two 2-element vectors and a scalar; and
% they must specify two positive coordinate ranges (1st element < 2nd) and
% one zero or negative range.  (A scalar counts as a zero range.)  The two
% positive ranges define the size and location of the rectangle in the X-Y,
% Y-Z or Z-X plane, as appropriate, and the third argument specifies the
% third coordinate and whether the 'top' surface (the one that reflects
% light) faces in the positive or negative direction: a zero range for
% positive and a negative range for negative.  For example, to create a
% floor rectangle from -1 to 2 in the x direction, from 0 to 1 in the y
% direction, with a z coordinate of 0.5 and facing in the +z direction, use
% X=[-1 2], Y=[0 1] and either Z=[0.5 0.5] or Z=0.5.  To make floor face in
% the -z direction, use Z=[0.5 c] where c is any number less than 0.5.
% Tilesize specifies the size of a single tile; and colour is a 1x3 or 2x3
% matrix specifying one or two colours.  If colour is a 1x3 matrix then it
% specifies the colour of the lighter tiles, the darker ones being a darker
% version of the same colour.  The arguments Z, tilesize and colour are all
% optional, and default to 0, 0.5 and [0.3 0.3 0.3] if omitted.  Tiles are
% positioned within the floor rectangle as if the tiling had started at the
% origin.  Tiles at the edge of the floor rectangle are allowed to stretch
% slightly to avoid thin slivers of tiles appearing at the edges.  This
% function arbitrarily insists that the floor rectangle be at least 1.5
% tiles wide in both directions.

% Implementation note:  Each tile is actually a pair of triangles because
% triangles render much faster than squares.  Also, single-colour patches
% render significantly faster than multicoloured ones, so the complete
% floor is made from two single-colour patches.

if nargin < 4
  Z = [0 0];
end
if nargin < 5
  tilesize = 0.5;
end
if nargin < 6
  colour = [0.3 0.3 0.3];
end

err = 0;
dims = [length(X) length(Y) length(Z)];
if any( dims > 2 ) || sum(dims) < 5
  err = 1;
else
  range = [X(end)-X(1), Y(end)-Y(1), Z(end)-Z(1)];
  if sum( range <= 0 ) ~= 1
    err = 1;
  end
end

if err == 1
  error(['arguments X, Y and Z must specify two positive ranges and '...
	 'one zero or negative range (or a scalar)']);
end

if range(1) <= 0			% tiles in Y-Z plane, X is up
  up = 1 - 2 * (range(1)<0);		% (or down if range < 0)
  height = X(1);
  U = Y;  V = Z;
elseif range(2) <= 0			% tiles in Z-X plane, Y is up/down
  up = 2 - 4 * (range(2)<0);
  height = Y(1);
  U = Z;  V = X;
else					% tiles in X-Y plane, Z is up/down
  up = 3 - 6 * (range(3)<0);
  height = Z(1);
  U = X;  V = Y;
end

if ~isscalar(tilesize) || tilesize <= 0
  error('tilesize must be a scalar > 0');
end

if U(2)-U(1) < 1.5*tilesize*(1-eps) || V(2)-V(1) < 1.5*tilesize*(1-eps)
  error('floor rectangle is too small for given (or default) tile size');
end

err = 0;
if all( size(colour) == [1,3] )
  colour1 = colour;
  colour2 = 0.75*colour;
elseif all( size(colour) == [2,3] )
  colour1 = colour(1,:);
  colour2 = colour(2,:);
else
  err = 1;
end

if err || any(any( colour < 0 )) || any(any( colour > 1 ))
  error('colour must be a 1x3 or 2x3 matrix of RGB colour values');
end

% Calculate the number of vertices in each direction.  Edge tiles are
% allowed to stretch 5% (0.05).

m0 = floor(U(1)/tilesize+0.05);
m1 = ceil(U(2)/tilesize-0.05);
m = m1 - m0 + 1;			% # vertices in U direction
n0 = floor(V(1)/tilesize+0.05);
n1 = ceil(V(2)/tilesize-0.05);
n = n1 - n0 + 1;			% # vertices in V direction

% Calculate the sets of U and V vertex coordinate values.  All interior
% values are integer multiples of tilesize from the origin.

u = [U(1), tilesize*(m0+1:m1-1), U(2)];
v = [V(1), tilesize*(n0+1:n1-1), V(2)];

% The code below is a clever way to make the vertices array (an (mn)x3
% matrix) without using for-loops.  Note that reshape() pulls elements out
% of its argument column by column.

U = u' * ones(1,n);
V = ones(m,1) * v;
if abs(up) == 1
  vertices = [ ones(m*n,1)*height reshape(U,m*n,1) reshape(V,m*n,1) ];
  normals = ones(m*n,1) * [1 0 0];
elseif abs(up) == 2
  vertices = [ reshape(V,m*n,1) ones(m*n,1)*height reshape(U,m*n,1) ];
  normals = ones(m*n,1) * [0 1 0];
else
  vertices = [ reshape(U,m*n,1) reshape(V,m*n,1) ones(m*n,1)*height ];
  normals = ones(m*n,1) * [0 0 1];
end

if up < 0
  normals = -normals;
end

% Now make the faces.  They are divided into two sets: one for each
% colour.  The matrices faces1 and faces2 contain the face data for each
% set.  The first step is to initialize them to matrices of the correct
% size, as this speeds up execution of the subsequent for-loops.  The
% for-loops then visit each tile in turn, and add it (as a pair of
% triangles) to either faces1 or faces2.

nf = (m-1)*(n-1)/2;
faces1 = zeros( 2*ceil(nf), 3 );
faces2 = zeros( 2*floor(nf), 3 );

k1 = 1;
k2 = 1;
for j = 1:n-1
  for i = 1:m-1
    if mod(mod(i,2)+j,2) == 0
      faces1(k1:k1+1,:) = i+m*(j-1) + [0 1 m+1; m+1 m 0];
      k1 = k1 + 2;
    else
      faces2(k2:k2+1,:) = i+m*(j-1) + [0 1 m+1; m+1 m 0];
      k2 = k2 + 2;
    end
  end
end

if up < 0				% to keep to the counter-clockwise
  faces1 = faces1(:,[3 2 1]);		% convention, even though it is not
  faces2 = faces2(:,[3 2 1]);		% strictly necessary
end

% Now make the floor as a group containing two patches: one for each colour
% of tile.  The specular strength and exponent are toned down to make the
% floor appear dull.

h = hggroup( 'Parent', parent );

patch( 'Parent', h, ...
       'Vertices', vertices, ...
       'VertexNormals', normals, ...
       'Faces', faces1, ...
       'FaceColor', colour1, ...
       'SpecularStrength', 0.3, ...
       'SpecularExponent', 5, ...
       'EdgeColor', 'none', ...
       'FaceLighting', 'gouraud', ...
       'BackFaceLighting', 'unlit' );

patch( 'Parent', h, ...
       'Vertices', vertices, ...
       'VertexNormals', normals, ...
       'Faces', faces2, ...
       'FaceColor', colour2, ...
       'SpecularStrength', 0.3, ...
       'SpecularExponent', 5, ...
       'EdgeColor', 'none', ...
       'FaceLighting', 'gouraud', ...
       'BackFaceLighting', 'unlit' );
end


%----------


function q = interpolate(qdata, tdata, t)

% INTERPOLATE calculate joint positions by linear interpolation
% q=interpolate(qdata,tdata,t)  calculates a joint position vector q for a
% given time t by linear interpolation.  qdata is a 2D array with time as
% the second dimension, and q is a column vector.

if t <= tdata(1)
  q = qdata(:,1);
elseif t >= tdata(end)
  q = qdata(:,end);
else
  lo = 1;
  hi = length(tdata);
  while hi-lo > 1
    mid = floor((hi+lo)/2);
    if t < tdata(mid)
      hi = mid;
    else
      lo = mid;
    end
  end
  s = (t-tdata(lo)) / (tdata(hi)-tdata(lo));
  q = s*qdata(:,hi) + (1-s)*qdata(:,lo);
end
end


%----------


function  keyhandler( source, event )

% KEYHANDLER  handle keyboard events in ShowMotion windows
% keyhandler(source,event)  is the callback function for all keyboard
% events in all ShowMotion windows.  The commands are the same in all
% windows.

global ShoMoData;

try					% does ShoMoData still exist?
  fig = ShoMoData.fig;
catch					% no, so delete the figure
  delete(gcbf);				% containing the source object
  return
end

switch event.Character
  
  case 'p'
    if ishandle(ShoMoData.panel.fig)
      delete(ShoMoData.panel.fig);
    else
      showpanel;
    end
    
  case { 'h', '?' }
    command_summary(1);
    
  case ' '
    if ShoMoData.animating
      ShoMoData.animating = 0;
    else
      animate;
    end
  
  case 'r'
    ShoMoData.autorepeat = ~ShoMoData.autorepeat;
    
  case '0'
    if ShoMoData.animating
      ShoMoData.animating = 0;
    else
      timectrl( 'rewind&toggle' );
      reposition;
      viewtrack;
    end

  case '1'
    speedctrl('reset');
  case ','
    speedctrl('slower');
  case  '.'
    speedctrl('faster');
  case '/'
    speedctrl('reverse');
    
  case 'Z'
    viewzoom( 1.02 );
  case 'z'
    viewzoom( 1/1.02 );
    
  case 'i'
    viewreset;
    
  case 'L'
    adjustlighting( 1, 0 );
  case 'l'
    adjustlighting( -1, 0 );
  case 'O'
    adjustlighting( 0, 1 );
  case 'o'
    adjustlighting( 0, -1 );

  otherwise
    
    if any(strcmp(event.Modifier,'control'))
      key = ['c-' event.Key];
    elseif any(strcmp(event.Modifier,'shift'))
      key = ['s-' event.Key];
    else
      key = event.Key;
    end
    
    switch key
      case 'uparrow'
	viewkeypan( 0, 1 );
      case 'downarrow'
	viewkeypan( 0, -1 );
      case 'leftarrow'
	viewkeypan( -1, 0 );
      case 'rightarrow'
	viewkeypan( 1, 0 );

      case 's-uparrow'
	viewrotate( [-1 0 0]*pi/60 );
      case 's-downarrow'
	viewrotate( [1 0 0]*pi/60 );
      case 's-leftarrow'
	viewrotate( [0 -1 0]*pi/60 );
      case 's-rightarrow'
	viewrotate( [0 1 0]*pi/60 );
      case 'c-leftarrow'
	viewrotate( [0 0 -1]*pi/90 );
      case 'c-rightarrow'
	viewrotate( [0 0 1]*pi/90 );
      
      case 'c-uparrow'
	viewzoom( 1/1.02 );
      case 'c-downarrow'
	viewzoom( 1.02 );
      
      case { 'n', 's-n', 'c-n', 'm', 's-m', 'c-m' }
	if key(1) == 'c'
	  arg = 1;
	elseif key(1) == 's'
	  arg = 2;
	else
	  arg = 3;
	end
	if key(end) == 'n'
	  arg = -arg;
	end
	ShoMoData.animating = 0;
	timectrl( 'key', arg );
	reposition;
	viewtrack;
    end
end

updatepanel;

end


%----------


function  loadfile( filename )
  
% loadfile  load and run a .mat file containing a showmotion animation
% loadfile(filename)  loads a .mat file with the given filename, checks
% that it contains all the necessary showmotion animation data, and calls
% showmotion to start a new animation.

  global  ShoMoData;

  try
    S = load( filename );
  catch
    s = lasterror;
    beep;
    fprintf( 2, '%s\n', s.message );
    return
  end

  if ~isfield(S,'model') || ~isfield(S,'t_data') || ...
	~isfield(S,'q_data') || ~isfield(S,'about')
    beep;
    fprintf( 2, ['Error using ==> loadfile\n''%s'' is not a valid ' ...
		 'showmotion animation file\n'], filename );
    return
  end

  if ~ismember(2,S.about.playable)
    beep;
    fprintf( 2, ['Error using ==> loadfile\n' ...
		 'This animation was created by version %g, and '...
		 'cannot be played by version 2\n'], S.about.creator );
    return
  end

  showmotion( S.model, S.t_data, S.q_data );

  ShoMoData.about = S.about;
end


%----------


function  h = lyne( parent, coords, colour )

% LYNE  make a line
% h=lyne(parent,coords,colour)  creates a line having the specified parent,
% coordinates and colour, and returns its handle.  Coords is an Nx3 matrix
% (N>=2) containing the sequence of points through which the line passes,
% and colour is an RGB triple.

if size(coords,2) ~= 3 || size(coords,1) < 2
  error('coords must be an Nx3 matrix, N>=2');
end

if ~isvector(colour) || length(colour) ~= 3
  error('colour must be an RGB triple');
end

X = coords(:,1);
Y = coords(:,2);
Z = coords(:,3);

h = line( 'Parent', parent, ...
	  'XData', X, ...
	  'YData', Y, ...
	  'ZData', Z, ...
	  'Color', colour );
end


%----------


function  camera = makecamera( model )

% MAKECAMERA  create a ShowMotion camera data structure
% camera = makecamera(model)  reads camera data from a model data structure
% and returns a ShowMotion camera data structure.

camera.trackbody = 0;
camera.trackpoint = [0 0 0];
camera.direction = [0 -1 0.8]/sqrt(1.64);  % vector from scene to camera
camera.up = [0 0 1];
camera.zoom = 1;
camera.locus = [];

if size(model.Xtree{1},1) == 3		% is model planar?
  g = get_gravity(model);		% (g is a planar vector)
  if g(3) < 0 && abs(g(3)) > abs(g(2))	% gravity approx in -y direction
    camera.up = [0 1 0];
    camera.direction = [0 0.4 1]/sqrt(1.16);
  end
end

if isfield( model, 'camera' )
  if isfield( model.camera, 'body' )
    b = model.camera.body;
    if ~isscalar(b) || b < 0 || b > model.NB
      error( 'model.camera.body: invalid body number' );
    else
      camera.trackbody = b;
    end
  end

  if isfield( model.camera, 'trackpoint' )
    p = model.camera.trackpoint;
    if ~isvector(p) || length(p) ~= 3
      error( 'model.camera.trackpoint must be a 3D vector' );
    else
      camera.trackpoint = [p(1) p(2) p(3)];
    end
  end

  if isfield( model.camera, 'direction' )
    d = model.camera.direction;
    if ~isvector(d) || length(d) ~= 3 || norm(d) == 0
      error( 'model.camera.direction must be a nonzero 3D vector' );
    else
      camera.direction = [d(1) d(2) d(3)] / norm(d);
    end
  end

  if isfield( model.camera, 'up' )
    u = model.camera.up;
    if ~isvector(u) || length(u) ~= 3 || norm(u) == 0
      error( 'model.camera.up must be a nonzero 3D vector' );
    else
      camera.up = [u(1) u(2) u(3)] / norm(u);
    end
  end
  if norm(camera.up-camera.direction) <= 2*eps
    error( 'camera.up and .direction must be different' );
  end

  if isfield( model.camera, 'zoom' )
    z = model.camera.zoom;
    if ~isscalar(z) || z <= 0
      error( 'model.camera.zoom must be a positive scalar' );
    else
      camera.zoom = z;
    end
  end

  if isfield( model.camera, 'locus' )
    loc = model.camera.locus;
    if ~isvector(loc) || length(loc) ~= 2 || any(abs(loc) > 1)
      error( ['model.camera.locus must be a 2D vector with elements'...
	      ' in the range -1 to 1'] );
    else
      camera.locus = loc;
    end
  end
end

end


%----------


function handles = makedrawing( model, parent )

% MAKEDRAWING  create drawing of model for ShowMotion
% handles=makedrawing(model,parent)  creates a handle-graphics rendering of
% the drawing instructions in the given model data structure for display by
% showmotion.  It returns an array of handles to hgtransform objects, one
% handle for each moving body in the model.  To position the individual
% bodies correctly, one must set the matrix of each hgtransform such that
% the matrix of handles(i) is the 4x4 homogeneous displacement operator
% from the base coordinate frame to the frame embedded in body i.
% makedrawing does not initialize these matrices.  Use the function
% reposition(q) to set these matrices to appropriate values.

if ~isfield( model, 'appearance' )
  error( 'model has no appearance field' );
else
  app = model.appearance;
end

if ~isfield( app, 'body' )
  error( 'appearance must have a subfield ''body''' );
end

if ~iscell(app.body) || length(app.body) ~= model.NB
  error( 'appearance.body must be a cell array of length model.NB' );
end

for i = 1:model.NB
  if length(app.body{i}) > 0 && ~iscell(app.body{i})
    error( 'appearance.body{%d} must be a cell array', i );
  end
end

if isfield( app, 'base' ) && length(app.base) > 0 && ~iscell(app.base)
  error( 'appearance.base must be a cell array' );
end

base = hggroup( 'Parent', parent );

context.facets = 24;
context.colour = defaultcolour(0);
context.vertices = [];

if isfield( app, 'base' )
  add_drawing( app.base, context, base, 0 );
end

for i = 1:model.NB
  handles(i) = hgtransform( 'Parent', base );
  context.colour = defaultcolour(i);
  add_drawing( app.body{i}, context, handles(i), i );
end
end



function  add_drawing( list, context, handle, index )

  function  str = location(i)
    str = sprintf( '{%d}', [index(2:end),i] );
    str = [ 'at location ', str, ' in drawing instructions for' ];
    str = sprintf( '%s body number %d', str, index(1) );
    if index(1) == 0
      str = [ str, ' (base)' ];
    end
  end

i = 1;
N = length(list);

one_arg = { 'box', 'line', 'triangles', 'colour', 'facets', 'vertices' };
two_args = { 'cyl', 'sphere', 'tiles' };
command_list = [ one_arg, two_args ];

while i <= N

  cmd = list{i};

  if iscell(cmd)
    add_drawing( cmd, context, handle, [index i] );
    i = i+1;
    continue
  end
  
  if ~ischar(cmd)
    error( 'string expected %s', location(i) );
  end
  
  if ~any(strcmp( cmd, command_list ))
    error( 'unrecognised command ''%s'' %s', cmd, location(i) );
  end

  if any(strcmp( cmd, one_arg ))
    nargs = 1;
  else
    nargs = 2;
  end
  
  if i + nargs > N
    error( 'drawing instructions end prematurely %s', location(N) );
  else
    arg1 = list{i+1};
    if nargs == 2
      arg2 = list{i+2};
    end
  end
  
  if ~isnumeric(arg1) || nargs == 2 && ~isnumeric(arg2)
    error( 'argument(s) of command ''%s'' must be numeric, %s', ...
	   cmd, location(i) );
  end
  
  switch cmd
    
    case 'box'
      try
	box( handle, arg1, context.colour(1,:) );
      catch
	s = lasterror;
	error('box error message "%s" %s', s.message, location(i));
      end
    
    case 'line'
      if isvector(arg1) && length(arg1) >= 2
	if length(context.vertices) == 0
	  error('no vertex data specified %s', location(i));
	elseif any(any(arg1<1)) || any(any(arg1>length(context.vertices)))
	  error('at least one vertex number out of range %s', location(i+1));
	else
	  arg1 = context.vertices(arg1,:);
        end
      elseif size(arg1,2) ~= 3
	error(['line data must be either a vector of vertex numbers or'...
	       ' an Nx3 array of coordinates, N>=2, %s'], location(i+1));
      end
      try
	lyne( handle, arg1, context.colour(1,:) );
      catch
	s = lasterror;
	error('line error message "%s" %s', s.message, location(i));
      end
      
    case 'triangles'
      if length(context.vertices) == 0
	error('no vertex data specified %s', location(i));
      elseif size(context.vertices,1) < 3
	error('not enough vertex data specified %s', location(i));
      end
      try
	triangles( handle, context.vertices, arg1, context.colour(1,:) );
      catch
	s = lasterror;
	error('triangles error message "%s" %s', s.message, location(i));
      end
    
    case 'colour'
      if size(arg1,2) ~= 3 || any(any(arg1<0)) || any(any(arg1>1))
	error( 'invalid RGB colour(s) %s', location(i+1) );
      else
	context.colour = arg1;
      end
    
    case 'facets'
      if ~isscalar(arg1) || arg1 < 3
	error( 'number of facets must be a scalar >= 3 %s', location(i+1) );
      else
	context.facets = arg1;
      end
    
    case 'vertices'
      if size(arg1,2) ~= 3 || size(arg1,1) < 2
	error( 'vertex array must be Nx3, N>=2, %s', location(i+1) );
      else
	context.vertices = arg1;
      end
    
    case 'cyl'
      coords = arg1;
      radius = arg2;
      try
	cylinder( handle, coords, radius, context.colour(1,:), ...
		  context.facets );
      catch
	s = lasterror;
	error('cylinder error message "%s" %s', s.message, location(i));
      end
    
    case 'sphere'
      coords = arg1;
      radius = arg2;
      try
	sphere( handle, coords, radius, context.colour, context.facets );
      catch
	s = lasterror;
	error('sphere error message "%s" %s', s.message, location(i));
      end
    
    case 'tiles'
      if index(1) ~= 0
	error('floor tiles must be in the base, %s', location(i));
      elseif ~all( size(arg1) == [3 2] )
	error('floor tiles first argument must be a 3x2 matrix, %s', ...
	      location(i+1));
      end
      Xrange = arg1(1,:);
      Yrange = arg1(2,:);
      Zrange = arg1(3,:);
      tilesize = arg2;
      try
	floortiles( handle, Xrange,Yrange,Zrange, tilesize, [0.3 0.3 0.3]);
      catch
	s = lasterror;
	error('floortiles error message "%s" %s', s.message, location(i));
      end
  end
  
  i = i + nargs+1;
end
end


%----------


function  lights = makelights( camera, ax )

% makelights  make overhead and camera lights
% makelights(camera,ax) creates and returns a data structure for managing
% an overhead light and a camera headlight.  The former is a light at
% infinity that shines from a fixed direction.  The latter is a local light
% that moves around with the camera.  (See adjustlighting.)  The direction
% of the overhead light depends on the camera's .up and .direction vectors.

  view_up = camera.up - camera.direction * dot(camera.up,camera.direction);
  view_up = view_up / norm(view_up);
  view_right = cross(view_up,camera.direction);
  light_dir = view_up + camera.up - 0.7 * view_right;

  lights.overhead = ...
      light( 'Parent', ax, 'Position', light_dir, ...
	     'Style', 'infinite', 'Color', [1 1 1] );

  lights.camera = ...
      light( 'Parent', ax, 'Position', [0 0 0], ...
	     'Style', 'local', 'Color', [1 1 1] );

  lights.overheadPower = 1;
  lights.cameraPower = 1;

end


%----------


function  makemenu

% MAKEMENU  make uicontext menu for ShowMotion main window
% makemenu makes the uicontext menu that appears when you right-click in
% the ShowMotion main window

% Implementation Note:  The uicontext menu is created as a property of the
% main figure because the intention is that you be able to invoke it
% anywhere within the main figure window.  However, to achieve this effect,
% it is necessary to switch off the HitTest property of every visible
% graphics object within the main figure.  This task is done by the
% function nohit().

  global ShoMoData;

  function csfn(source,event)		% call up a command summary
    command_summary(1);
  end

  function cpfn(source,event)		% call up a control panel
    showpanel;
    if ~ShoMoData.animating
      updatepanel;
    end
  end

  function dscfn(source,event)		% describe this animation
    commandwindow;
    about;
  end

  function clsfn(source,event)		% close main window
    delete(ShoMoData.fig);
  end

  function nohit(h)			% recursively switch off HitTest
    set( h, 'HitTest', 'off' );
    switch get(h,'Type')
      case { 'hggroup', 'hgtransform', 'axes' }
	c = get(h,'Children');
	for h = c'
	  nohit(h);
        end
    end
  end

  h = uicontextmenu( 'Parent', ShoMoData.fig );
  uimenu( h, 'Label', 'show command summary','Callback', @csfn );
  uimenu( h, 'Label', 'show control panel', 'Callback', @cpfn );
  uimenu( h, 'Label', 'describe this animation', 'Callback', @dscfn );
  uimenu( h, 'Label', 'exit from showmotion', 'Callback', @clsfn );
  set( ShoMoData.fig, 'UIContextMenu', h );
  nohit( ShoMoData.ax );

end


%----------


function  panel = makepanel

% MAKEPANEL  make the control panel data structure
% panel=makepanel  creates a new initial control panel data structure.  The
% returned structure lacks fields for the handles of graphical objects and
% state variables indicating the state of those objects.  Those missing
% fields are created by showpanel.

global ShoMoData;

panel.red = [0.75 0 0];			% colour scheme
panel.orange = [1 0.7 0];
panel.green = [0.4 0.7 0.3];
panel.grey = [0.5 0.54 0.56];

panel.width = 427;			% panel size in pixels
panel.height = 80;

panel.xy.play = [12 51];		% layout data
panel.xy.stop = [50 55];
panel.xy.repeat = [81 55];
panel.xy.help = [118 60];
panel.xy.direction = [252 55];
panel.xy.speedDisplay = [369 61];
panel.xy.speedSlider = [286 60];
panel.xy.speedLabel = [246 61];		% aligned right
panel.xy.timeLabel = [12 32];
panel.xy.timeDisplay = [65 32];
panel.xy.timeSlider = [13 12];
panel.xy.fineLabel = [303 35];		% aligned right
panel.xy.fineSlider = [313 33];

panel.figpos = [];			% figure position not yet known
panel.fig = NaN;				% no figure yet

% now make the icons

icon1 = [0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0;...
	 0 0 0 0 0 0 0 0 0 1 1 2 1 0 0 0 0 0 0 0;...
	 0 0 0 0 0 0 0 0 1 1 2 2 1 0 0 0 0 0 0 0;...
	 0 0 0 0 0 0 0 1 1 2 2 2 1 0 0 0 0 0 0 0;...
	 0 0 0 0 0 0 1 1 2 2 2 2 1 1 1 0 0 0 0 0;...
	 0 0 0 1 1 1 1 2 2 2 2 2 2 2 2 1 1 0 0 0;...
	 0 0 1 2 2 1 2 2 2 2 2 2 2 2 2 2 2 1 0 0;...
	 0 1 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 1 0;...
	 0 1 2 2 2 2 1 1 2 2 2 2 1 1 2 2 2 2 1 0;...
	 1 2 2 2 2 1 0 1 1 2 2 2 1 0 1 2 2 2 2 1;...
	 1 2 2 2 1 0 0 0 1 1 2 2 1 0 0 1 2 2 2 1;...
	 1 2 2 2 1 0 0 0 0 1 1 2 1 0 0 1 2 2 2 1;...
	 1 2 2 2 1 0 0 0 0 0 1 1 1 0 0 1 2 2 2 1;...
	 1 2 2 2 1 0 0 0 0 0 0 0 0 0 0 1 2 2 2 1;...
	 1 2 2 2 2 1 0 0 0 0 0 0 0 0 1 2 2 2 2 1;...
	 0 1 2 2 2 2 1 1 1 1 1 1 1 1 2 2 2 2 1 0;...
	 0 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 0;...
	 0 0 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 0 0;...
	 0 0 0 1 1 2 2 2 2 2 2 2 2 2 2 1 1 0 0 0;...
	 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0];

icon2 = [0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0;...
	 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 1 0 0 0 0 0 0;...
	 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 2 1 0 0 0 0 0;...
	 0 0 0 0 0 0 0 0 0 1 1 1 1 1 2 2 2 1 0 0 0 0;...
	 0 0 0 0 0 0 0 0 0 2 2 2 2 2 2 2 2 2 1 0 0 0;...
	 0 0 0 0 0 1 1 0 0 2 2 2 2 2 2 2 2 2 2 1 0 0;...
	 0 0 0 0 1 3 1 0 0 2 2 2 2 2 2 2 2 2 2 2 1 0;...
	 0 0 0 1 3 3 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 1;...
	 0 0 1 3 3 3 3 3 3 2 2 2 2 2 2 2 2 2 2 2 1 0;...
	 0 1 3 3 3 3 3 3 3 2 2 2 2 2 2 2 2 2 2 1 0 0;...
	 1 3 3 3 3 3 3 3 3 2 2 2 2 2 2 2 2 2 1 0 0 0;...
	 0 1 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 1 0 0 0 0;...
	 0 0 1 3 3 3 3 3 3 3 3 0 0 1 2 2 1 0 0 0 0 0;...
	 0 0 0 1 3 3 1 1 1 1 1 0 0 1 2 1 0 0 0 0 0 0;...
	 0 0 0 0 1 3 1 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0;...
	 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

colour1 = [panel.grey; [0 0 0]; panel.red];
colour2 = [panel.grey; [0 0 0]; panel.orange; panel.red];

off = zeros(20,20,3);
on = zeros(20,20,3);
fwd = zeros(16,22,3);
rev = zeros(16,22,3);

for i = 1:20
  for j = 1:20
    off(i,j,:) = colour1( icon1(21-i,j)+1, :);
    on(i,j,:) = colour2( icon1(21-i,j)+1, :);
  end
end

for i = 1:16
  for j = 1:22
    fwd(i,j,:) = colour2( icon2(17-i,j)+1, :);
    rev(i,j,:) = colour2( icon2(i,23-j)+1, :);
  end
end

panel.repeat_off = off;
panel.repeat_on = on;
panel.forward = fwd;
panel.reverse = rev;

end


%----------


function  mousehandler( source, event, mycode )

% MOUSEHANDLER  handle mouse events in ShowMotion main window
% mousehandler(source,event,mycode) is the callback function for all mouse
% events in the main ShowMotion window except the menu.  In particular,
% this function manages rotate, pan, zoom and refocus.

global ShoMoData;

try					% does ShoMoData still exist?
  fig = ShoMoData.fig;
catch
  delete(source);
  return
end

switch mycode

  case 'down'				% button press

    cmd = get( fig, 'SelectionType' );

    switch cmd

      case 'normal'			% start rotating

	ShoMoData.vw_last_pt = get( fig, 'CurrentPoint' );
	ShoMoData.vw_mode = 'rotate';
	adjustball(1);

      case 'extend'			% start panning

	adjustball(0);
	ShoMoData.vw_last_pt = get( fig, 'CurrentPoint' );
	ShoMoData.vw_mode = 'pan';
	set( fig, 'Pointer', 'fleur' );
    end

  case 'up'				% button release

    adjustball(0);
    set( fig, 'Pointer', 'arrow' );
    ShoMoData.vw_mode = 'normal';

  case 'move'				% mouse movement

    pt = get( fig, 'CurrentPoint' );
    switch ShoMoData.vw_mode
      case 'rotate'
	viewmouserot( pt, ShoMoData.vw_last_pt );
	ShoMoData.vw_last_pt = pt;
      case 'pan'
	viewmousepan( pt, ShoMoData.vw_last_pt );
	ShoMoData.vw_last_pt = pt;
    end

  case 'scroll'				% scroll wheel

    switch ShoMoData.vw_mode
      case 'rotate'
	viewrefocus( 1 + event.VerticalScrollCount/25 );
      otherwise
	viewzoom( 1 + event.VerticalScrollCount/8 );
    end

end
end


%----------


function  pos = mousepos( pix )

% MOUSEPOS  calculate normalized mouse cursor coordinates
% pos=mousepos(pix)  converts a mouse cursor location from figure pixel
% coordinates to a normalized coordinate system in which (0,0) corresponds
% to the centre of the figure window, and the narrower of its two
% dimensions maps to the range [-1,1].  (The other dimension will therefore
% map to a wider range.)  The angle at the camera between (0,-1) and (0,1),
% or between (-1,0) and (1,0), equals the camera's viewing angle.

% NOTE:  From my experiments, Matlab appears to regard pixel coordinates as
% referring to the centre of a pixel, whereas the pyramid defined by the
% camera's viewing angle maps to the edges of the pixels on the rectangle's
% boundary.  Thus, the largest angle between any two pixels in the shorter
% dimension will be slightly less than the camera's viewing angle.  This
% Matlab behaviour is accommodated here in mousepos by mapping pixel edges
% to the range [-1,1] and returning the coordinates of pixel centres.

global ShoMoData;

figrectangle = get( ShoMoData.fig, 'Position' );
width = figrectangle(3);
height = figrectangle(4);
middle = [ (width+1)/2, (height+1)/2 ];
scaling = min(width,height) / 2;

pos = (pix - middle) / scaling;

end


%----------


function  ray = mouseray( pos )

% MOUSERAY  calculate ray from camera position through mouse cursor
% ray=mouseray(pos) calculates a unit vector, expressed in camera
% coordinates, pointing from the camera's position towards the given cursor
% position, pos, expressed in normalized mouse coordinates (see mousepos).

global ShoMoData;

viewangle = ShoMoData.view.angle;

d = tan(viewangle/2);

ray = [ pos(1)*d; pos(2)*d; -1 ];

ray = ray / norm(ray);

end


%----------


function  panelhandler( source, event, code )

% PANELHANDLER  handle mouse events in ShowMotion control panel
% panelhandler(source,event,code) is the event callback function for mouse
% click and drag events in the ShowMotion control panel.  It handles all
% slider dragging and clicking on the control panel's buttons.

global ShoMoData;

try					% does ShoMoData still exist?
  fig = ShoMoData.fig;
catch
  delete(gcbf);				% delete figure (=control panel)
  return				% containing the source object
end

switch code
  
  case 'play'
    if ShoMoData.animating
      ShoMoData.animating = 0;
    else
      animate;
    end
    
  case 'stop'
    if ShoMoData.animating
      ShoMoData.animating = 0;
    else
      timectrl('rewind&toggle');
      reposition;
      viewtrack;
    end
    
  case 'repeat'
    ShoMoData.autorepeat = ~ShoMoData.autorepeat;
    
  case 'help'
    command_summary(1);
    
  case 'reverse'
    speedctrl('reverse');
    
  case 'slider'
    % initialize the data structure panel.drag and install the necessary
    % window callback functions for dragging.  drag.pos is initialized to
    % the current position of the affected slider; drag.mode identifies the
    % slider; and drag.x contains the x coordinate of the cursor.  As the
    % cursor is moved, both drag.x and drag.pos follow it (see case 'drag'
    % below).  This means that drag.pos contains the *unclipped* slider
    % position; i.e., the position before range limits have been applied.
    panel = ShoMoData.panel;
    drag.pos = get( source, 'UserData' );
    if source == panel.speedSlider
      drag.mode = 'speed';
    elseif source == panel.coarseSlider
      drag.mode = 'coarse';
      ShoMoData.animating = 0;
    else
      drag.mode = 'fine';
      ShoMoData.animating = 0;
    end
    set( panel.fig, ...
	 'WindowButtonMotionFcn', {@panelhandler, 'drag'}, ...
	 'WindowButtonUpFcn', {@panelhandler, 'up'} );
    cp = get( panel.fig, 'CurrentPoint' );
    drag.x = cp(1);
    ShoMoData.panel.drag = drag;

  case 'drag'
    panel = ShoMoData.panel;
    drag = panel.drag;
    cp = get( panel.fig, 'CurrentPoint' );
    drag.pos = drag.pos + cp(1) - drag.x;
    drag.x = cp(1);
    ShoMoData.panel.drag = drag;
    switch drag.mode
      case 'speed'
	speedctrl( 'drag', drag.pos );
      case 'fine'
	timectrl( 'dragF', drag.pos );
	reposition;
	viewtrack;
      case 'coarse'
	timectrl( 'dragC', drag.pos );
	reposition;
	viewtrack;
    end

  case 'up'
    % this code removes the drag-related callbacks; and if the slider being
    % dragged happens to be the fine slider then it also applies a
    % 'recentre' operation, which nudges the coarse slider a bit and brings
    % the fine slider back to centre if it happens to be at an extremum.
    panel = ShoMoData.panel;
    drag = panel.drag;
    if strcmp( drag.mode, 'fine' )
      timectrl('recentre');
    end
    set( panel.fig, ...
	 'WindowButtonMotionFcn', '', ...
	 'WindowButtonUpFcn', '' );
end

updatepanel;

end


%----------


function  reposition( q )

% REPOSITION  adjust position of graphical (robot) model
% reposition(q)  adjusts the positions of the moving bodies in a ShowMotion
% animation.  The argument is a joint position vector.  If the argument is
% omitted then reposition uses the joint position vector for the current
% view time, as given by tview.

  global ShoMoData;

  if nargin == 0
    q = interpolate( ShoMoData.q_data, ShoMoData.t_data, ShoMoData.tview );
  end

  model = ShoMoData.model;
  handles = ShoMoData.handles;

  for i = 1:model.NB
    XJ = jcalc( model.jtype{i}, q(i) );
    Xa{i} = XJ * model.Xtree{i};
    if model.parent(i) ~= 0
      Xa{i} = Xa{i} * Xa{model.parent(i)};
    end
    if size(Xa{i},1) == 3		% Xa{i} is a planar coordinate xform
      [theta,r] = plnr(Xa{i});
      X = rotz(theta) * xlt([r;0]);
      T = pluho(X);
    else
      T = pluho(Xa{i});
    end
    Tdisp = inv(T);		% displacement is inverse of coord xform
    set( handles(i), 'matrix', Tdisp );
  end
end


%----------


function  savefile( filename )

% savefile  save the current animation in a .mat file
% savefile(filename)  saves the current animation in a .mat file having the
% given name.

  global  ShoMoData;

  if ~isstruct(ShoMoData)
    error('There is no animation data to save');
  end

  model = ShoMoData.model;
  t_data = ShoMoData.t_data;
  q_data = ShoMoData.q_data;
  about = ShoMoData.about;
  
  about.creator = 2;		% version of showmotion creating this file
  about.playable = 2;		% list of versions capable of playing it
  about.date = date;		% new creation date

  save( filename, 'model', 't_data', 'q_data', 'about' );

end


%----------


function  showpanel

% SHOWPANEL  display a ShowMotion control panel
% showpanel  either creates a new window, or raises an existing one,
% displaying a ShowMotion control panel.

global ShoMoData;

  function  deletefn(source,event)	% delete callback
    try
      rect = get( ShoMoData.panel.fig, 'Position' );
      ShoMoData.panel.figpos = rect(1:2);
      ShoMoData.panel.fig = NaN;	% because Matlab recycles handles
    catch
      % ShoMoData has been cleared (e.g. by 'clear all' command)
    end
  end

panel = ShoMoData.panel;

% If a control panel currently exists, then simply raise it and return

if ishandle(panel.fig)
  figure(panel.fig);			% this call 'raises' a figure
  return
end

% Create a new control panel figure

fig = figure( 'Renderer', 'OpenGL', ...
	      'Color', panel.grey, ...
	      'Resize', 'off', ...
	      'HandleVisibility', 'callback', ...
	      'Name', 'ShowMotion Control Panel', ...
	      'NumberTitle', 'off', ...
	      'MenuBar', 'none', ...
	      'KeyPressFcn', @keyhandler, ...
	      'DeleteFcn', @deletefn );
panel.fig = fig;

if length(panel.figpos) == 0		% no known prior position
  rect = get( fig, 'Position' );
  panel.figpos = rect(1:2);
end

set( fig, 'Position', [panel.figpos panel.width panel.height] );
drawnow;

% Create a new axes for the figure.  The values of XLim and YLim are
% intended to make pixel and data coordinates coincide

ax = axes( 'Parent', fig, ...
	   'Position', [0 0 1 1], ...
	   'Visible', 'off', ...
	   'XLim', [0.5 panel.width+0.5], ...
	   'YLim', [0.5 panel.height+0.5] );
panel.ax = ax;

% Create 'play', 'stop', 'repeat' and 'help' buttons.  'play' and 'repeat'
% need state variables because they can change their appearance

panel.playing = 0;
panel.play = patch( 'Parent', ax, ...
		    'XData', [0 24 0] + panel.xy.play(1), ...
		    'YData', [0 12 24] + panel.xy.play(2), ...
		    'FaceColor', panel.red, ...
		    'ButtonDownFcn', {@panelhandler, 'play'} );

patch( 'Parent', ax, ...
       'XData', [0 16 16 0] + panel.xy.stop(1), ...
       'YData', [0 0 16 16] + panel.xy.stop(2), ...
       'FaceColor', panel.red, ...
       'ButtonDownFcn', {@panelhandler, 'stop'} );

width = size(panel.repeat_off,2);
height = size(panel.repeat_off,1);
panel.repeating = 0;
panel.repeat = image( 'Parent', ax, ...
		      'XData', [0 width-1] + panel.xy.repeat(1), ...
		      'YData', [0 height-1] + panel.xy.repeat(2), ...
		      'CData', panel.repeat_off, ...
		      'ButtonDownFcn', {@panelhandler, 'repeat'} );

text( 'Parent', ax, ...
      'Position', [panel.xy.help 0], ...
      'String', 'help', ...
      'Color', panel.green, ...
      'FontSize', 16, ...
      'FontWeight', 'bold', ...
      'ButtonDownFcn', {@panelhandler, 'help'} );

% Create the 'time' and 'fine time' labels, the coarse and fine time
% sliders and the time display string.  Also initialize panel.updated=-1
% (the last time the time display string was updated).

text( 'Parent', ax, ...
      'Position', [panel.xy.timeLabel 0], ...
      'String', 'time:', ...
      'FontSize', 16, ...
      'FontWeight', 'bold' );

text( 'Parent', ax, ...
      'Position', [panel.xy.fineLabel 0], ...
      'String', 'fine time:', ...
      'HorizontalAlignment', 'right', ...
      'FontSize', 12, ...
      'FontWeight', 'bold' );

panel.timeDisplay = ...
    text( 'Parent', ax, ...
	  'Position', [panel.xy.timeDisplay 0], ...
	  'String', '0.0000', ...	% a dummy value
	  'FontSize', 16 );

panel.updated = -1;

panel.coarseSlider = ...
    make_slider( ax, panel.xy.timeSlider, ...
		 ShoMoData.time.coarseRange, ...
		 panel.red, panel.grey );

panel.fineSlider = ...
    make_slider( ax, panel.xy.fineSlider, ...
		 ShoMoData.time.fineRange, ...
		 panel.red, panel.grey );

% Make the speed display string, slider and label.

speed = ShoMoData.speed;

text( 'Parent', ax, ...
      'Position', [panel.xy.speedLabel 0], ...
      'String', 'speed:', ...
      'HorizontalAlignment', 'right', ...
      'FontSize', 12, ...
      'FontWeight', 'bold' );

if speed.sgn == 1
  icon = panel.forward;
  panel.goingfwd = 1;
else
  icon = panel.reverse;
  panel.goingfwd = 0;
end
width = size(icon,2);
height = size(icon,1);
panel.direction = ...
    image( 'Parent', ax, ...
	   'XData', [0 width-1] + panel.xy.direction(1), ...
	   'YData', [0 height-1] + panel.xy.direction(2), ...
	   'CData', icon, ...
	   'ButtonDownFcn', {@panelhandler, 'reverse'} );

panel.speedSlider = ...
    make_slider( ax, [panel.xy.speedSlider], ...
		 speed.range, panel.red, panel.grey );

panel.speedDisplay = ...
    text( 'Parent', ax, ...
	  'Position', [panel.xy.speedDisplay 0], ...
	  'String', speed.displaystring, ...
	  'FontSize', 12, ...
	  'FontWeight', 'bold' );

ShoMoData.panel = panel;


function  handle = make_slider( parent, pos, range, red, grey )

% MAKE_SLIDER  create a slider in ShowMotion's control panel
% handle=make_slider(parent,pos,range,red,grey) creates a slider in
% ShowMotion's control panel.  The argument pos specifies the x-y pixel
% coordinates of the slider's slot, and range specifies the sliding range
% in pixels.  (The actual range is 0..range, so the slider has range+1
% possible positions.  The slot is range+3 pixels long.)  The return value
% is the handle of the slider's moving pointer.  The pointer's position is
% stored in the 'UserData' field and must be updated as the slider is
% moved.  (The function that moves a slider is called adjust_slider, and is
% a nested function within updatepanel.)

if range < 200				% small slider
  slot = 5;
  height = 10;
  depth = 4;
  side = 8;
else					% big slider
  slot = 5;
  height = 11;
  depth = 5;
  side = 9;
end

patch( 'Parent', parent, ...
       'XData', [0 range+3 range+3 0] + pos(1), ...
       'YData', [0 0 slot slot] + pos(2), ...
       'FaceColor', 0.8 * grey );

handle = patch( 'Parent', parent, ...
		'XData', [-side side 1 -1] +1 + pos(1), ...
		'YData', [-depth -depth height height] + pos(2), ...
		'ZData', [1 1 1 1], ...
		'FaceColor', red, ...
		'UserData', 0, ...	% actual position of pointer
		'ButtonDownFcn', {@panelhandler, 'slider'} );
end

end					% because there are nested functions


%----------


function  speedctrl( cmd, arg )

% SPEEDCTRL  ShowMotion animation speed control
% speedctrl(cmd,arg) performs several functions relating to the setting,
% adjustment and display of ShowMotion animation speed.  The first argument
% is a string indicating what is to be done: 'initialize' --> initialize
% the speed data structure in ShoMoData; 'faster' --> increment speed
% magnitude; 'slower' --> decrement speed magnitude; 'reverse' --> reverse
% the direction of animation (i.e., change the sign of the speed); 'reset'
% --> set speed to +1; 'drag' --> speed adjustment via slider (arg ==
% slider position).

% ALGORITHM: except for 'initialize', which creates the data structure
% ShoMoData.speed, all the other functions work by modifying the two
% numbers .ix (meaning ShoMoData.speed.ix) and .sgn.  The former is an
% index into the nonlinear speed scale in .scale, and the latter is +/-1.
% The actual speed is therefore .sgn * .scale(.ix).  All other
% speed-related quantities are then computed from these two numbers.
%
% The speed slider features a snap of radius 2 pixels around the speed +1.
% This snap is implemented here in the code that maps incoming slider
% positions (the value of arg when cmd=='drag') to .sgn and .ix, and the
% code that maps .sgn and .ix to .sliderpos (the visual position of the
% slider).

global ShoMoData;

if strcmp( cmd, 'initialize' )		% initialize ShoMoData.speed

  E20 = [112 125 141 158 178 200 224 250 282 316 ...
	 355 400 450 500 560 630 710 790 890 1000];
  speed.scale = ...
      [ 0.001 0.0014 0.0019 0.0026 0.0035 0.0046 0.006 0.0078 ...
	0.01 0.0126 0.0158 0.0196 0.0241 0.0293 0.0354 0.0422 ...
	0.05 0.058 0.068 0.078 0.089 0.1 ...
	E20/1000 E20/100 E20(1:6)/10 ];
  len = length(speed.scale);
  speed.range = len +4 -1;		% range of speed slider
  speed.unity = 42;			% index value for unit speed
  speed.ix = speed.unity;
  speed.sgn = 1;

else

  speed = ShoMoData.speed;

  switch cmd
    case 'faster'			% increment speed magnitude
      if speed.ix == speed.unity-1 || speed.ix == length(speed.scale)-1
	speed.ix = speed.ix + 1;
      elseif speed.ix < length(speed.scale)
	speed.ix = speed.ix + 2;
      end
    case 'slower'			% decrement speed magnitude
      if speed.ix == speed.unity+1 || speed.ix == 2
	speed.ix = speed.ix - 1;
      elseif speed.ix > 1
	speed.ix = speed.ix - 2;
      end
    case 'reverse'			% change speed sign
      speed.sgn = - speed.sgn;
    case 'reset'			% set speed to +1
      speed.sgn = 1;
      speed.ix = speed.unity;
    case 'drag'				% adjust speed from slider position
      arg = max( 0, min( speed.range, arg ));
      if arg < speed.unity-1
	speed.ix = arg+1;
      elseif arg < speed.unity+4
	speed.ix = speed.unity;
      else
	speed.ix = arg-3;
      end
    otherwise
      error('unknown speed command ''%s''', cmd);
  end
end

% Now calculate new values for .speed (the speed value used by animate),
% .sliderpos (the displayed position of the speed slider) and
% .displaystring (the number showing the speed on the control panel).

speed.speed = speed.sgn * speed.scale(speed.ix);

if speed.ix < speed.unity
  speed.sliderpos = speed.ix -1;
elseif speed.ix == speed.unity
  speed.sliderpos = speed.ix +1;
else
  speed.sliderpos = speed.ix +3;
end

if speed.sgn < 0
  sign = '-';
else
  sign = ' ';
end
mag = sprintf( '%g', speed.scale(speed.ix) );
speed.displaystring = [ sign mag ];

ShoMoData.speed = speed;		% and finally, save the changes!

end


%----------


function h = sphere( parent, centre, radius, colour, facets )

% SPHERE  make a patch surface in the shape of a sphere
% h=sphere(parent,centre,radius,colour,facets)  creates a sphere having the
% specified parent, geometry and colour, and returns its handle.  If colour
% is a 2x3 matrix then a two-tone sphere is created, with the colours
% alternating between octants.  Facets specifies the number of triangles
% around the equator.  It should be a multiple of 4.  If omitted, facets
% defaults to 24.

if all( size(centre) == [3,1] )
  centre = centre';
elseif ~all( size(centre) == [1,3] )
  error('centre must be a 3D vector');
end

if ~isscalar(radius) || radius <= 0
  error('radius must ba a scalar > 0');
end

if all( size(colour) == [1,3] )
  colour = [colour; colour];
elseif ~all( size(colour) == [2,3] )
  error('colour must be a 1x3 or 2x3 matrix');
end

if nargin < 5
  facets = 24;
end

if ~isscalar(facets) || facets <= 0
  error('facets must ba a scalar > 0');
end

% The sphere is created from eight spherical octants.  This first step
% creates the vertices for a unit-radius octant at the origin, and then
% scales them to the correct radius.  Note that the vertex data also
% defines the vertex normals.  If N is the number of triangle edges along
% an octant edge, then the octant will contain 1+2+3+...+(N+1) =
% (N+1)(N+2)/2 vertices and 1+3+5+...+(2N-1) = N^2 triangles.

N = ceil(facets/4);			% number of triangles on octant edge

vertices = [0 0 1];			% apex (top row) of octant

for i = 1:N				% append vertices row by row
  z = cos(i/N*pi/2) * ones(i+1,1);
  s = sin(i/N*pi/2);
  x = cos((0:i)'/i*pi/2);
  y = sin((0:i)'/i*pi/2);
  vertices = [ vertices; s*x s*y z ];
end

vertices = vertices * radius;		% scale to correct size

% Make the offset matrix that will move the vertices to their correct
% locations in space.

offset = ones((N+1)*(N+2)/2,1) * centre;

% Now make the vertices for each octant.  At the end of this step, the
% vertices for octant number i are given by the expression V{i}+offset, and
% the vertex normals by V{i}.

R1 = [0 -1 0; 1 0 0; 0 0 1];		% 90 degree z rotation
R2 = [1 0 0; 0 -1 0; 0 0 -1];		% 180 degree x rotation

V{1} = vertices;
V{2} = V{1} * R1;
V{3} = V{2} * R1;
V{4} = V{3} * R1;
V{5} = V{1} * R2;
V{6} = V{5} * R1;
V{7} = V{6} * R1;
V{8} = V{7} * R1;

% Now make the face data.  This is the same for all octants.

faces = [1 2 3];			% triangle at apex (top row)

for i = 2:N				% append triangles row by row
  a = i*(i-1)/2;
  b = a+i;
  f1 = [ a+(1:i)', b+(1:i)', b+(2:i+1)' ];	% triangles pointing up
  f2 = [ a+(1:i-1)', b+(2:i)', a+(2:i)' ];	% triangles pointing down
  faces = [ faces; f1; f2 ];
end

% Now make the sphere.

h = hggroup( 'Parent', parent );

for i = 1:8
  patch( 'Parent', h, ...
	 'Vertices', V{i}+offset, ...
	 'VertexNormals', V{i}, ...
	 'Faces', faces, ...
	 'FaceColor', colour(1+mod(i,2),:), ...
	 'EdgeColor', 'none', ...
	 'FaceLighting', 'gouraud', ...
	 'BackFaceLighting', 'unlit' );
end
end


%----------


function  out = timectrl( cmd, arg )

% TIMECTRL  ShowMotion animation time control
% out=timectrl(cmd,arg) performs several functions relating to the setting,
% adjustment and display of ShowMotion animation time.  This function is
% mainly concerned with three numbers: .tview (meaning ShoMoData.tview),
% .time.cSliderPos and .time.fSliderPos, which determine the time of the
% current view and the positions of the two time sliders.  These quantities
% are inter-related, and changes in any one can drive changes in the other
% two.  The first argument is a string indicating what is to be done:
% 'initialize'    initialize the fields .tmin, .tmax and .tview, and the
%                 structure .time, from .t_data;
% 'set'           set .tview to given value and adjust slider positions
%                 appropriately;
% 'rewind&toggle' set .tview to beginning/end and adjust slider positions
%                 appropriately;
% 'key'           jog time forward or backward in response to keyboard
%                 commands, the argument being +/-1, +/-2 or +/-3 for a
%                 small/medium/big jog;
% 'dragF'/'dragC' set the fine/coarse time slider position and make
%                 consequential changes to the other two time values;
% 'recentre'      move fine slider from extreme position back to centre,
%                 adjusting the coarse slider appropriately;
% 'timestring'    return a string showing the value of .tview (its format
%                 varies with animation speed);
% 'finefreq'      return the cycling frequency of the fine slider at the
%                 current animation speed.

global ShoMoData;

CMAX = 400;				% coarse slider range
FMAX = 100;				% fine slider range
FMID = FMAX/2;				% fine slider mid point
CFR = FMAX/4;				% coarse/fine ratio
RESOL = CMAX*CFR;			% total # fine steps in full range

switch cmd

  case 'initialize'			% initialize ShoMoData.tmin, .tmax,
					% .tview and .time
    tmin = ShoMoData.t_data(1);
    tmax = ShoMoData.t_data(end);
    ShoMoData.tmin = tmin;
    ShoMoData.tmax = tmax;
    ShoMoData.tview = tmin;
    time.coarseRange = CMAX;
    time.fineRange = FMAX;
    time.cSliderPos = 0;
    time.fSliderPos = FMID;
    ShoMoData.time = time;

  case 'set'				% set .tview to given value

    time = ShoMoData.time;
    tmin = ShoMoData.tmin;
    tmax = ShoMoData.tmax;
    tview = max( tmin, min( tmax, arg ));
    t = (tview - tmin) * CMAX / (tmax - tmin);
    ShoMoData.tview = tview;
    time.cSliderPos = round(t);
    time.fSliderPos = FMID + round( CFR * (t - round(t)) );
    ShoMoData.time = time;

  case 'rewind&toggle'			% if .tview at a range limit then
					% go to other limit, else rewind
    if ShoMoData.tview >= ShoMoData.tmax
      timectrl( 'set', ShoMoData.tmin );
    elseif ShoMoData.tview <= ShoMoData.tmin
      timectrl( 'set', ShoMoData.tmax );
    elseif ShoMoData.speed.sgn > 0
      timectrl( 'set', ShoMoData.tmin );
    else
      timectrl( 'set', ShoMoData.tmax );
    end

  case 'key'				% adjust .tview in response to
					% keyboard command
    if ~any( arg == [-3 -2 -1 1 2 3] )
      error('invalid argument for operation ''key''');
    end
    mult = [1 10 100];
    mult = sign(arg) * mult(abs(arg));
    tmin = ShoMoData.tmin;
    tmax = ShoMoData.tmax;
    dt = (tmax - tmin) / RESOL;
    tview = ShoMoData.tview + mult*dt;
    timectrl( 'set', tview );

  case 'dragF'				% new fine slider position

    time = ShoMoData.time;
    cp0 = time.cSliderPos;
    cp1 = CMAX - cp0;
    fpmin = CFR * max( 0, 2-cp0 );
    fpmax = CFR * min( 4, 2+cp1 );
    fp = min( fpmax, max( fpmin, arg ));
    time.fSliderPos = fp;
    tmin = ShoMoData.tmin;
    range = ShoMoData.tmax - tmin;
    ShoMoData.tview = tmin + range/CMAX * (time.cSliderPos + (fp-FMID)/CFR);
    ShoMoData.time = time;

  case 'dragC'				% new coarse slider position

    time = ShoMoData.time;
    fp = time.fSliderPos;
    cp = time.cSliderPos;
    newcp = min( CMAX, max( 0, arg ));
    if newcp ~= arg
      fp = FMID;
    elseif newcp > cp && fp > FMID
      fp = max( FMID, fp - CFR*(newcp-cp) );
    elseif newcp < cp && fp < FMID
      fp = min( FMID, fp - CFR*(newcp-cp) );
    end
    time.fSliderPos = fp;
    time.cSliderPos = newcp;
    tmin = ShoMoData.tmin;
    range = ShoMoData.tmax - tmin;
    ShoMoData.tview = tmin + range/CMAX * (newcp + (fp-FMID)/CFR);
    ShoMoData.time = time;

  case 'recentre'			% if fine slider at range limit
					% then bring it back to centre
    time = ShoMoData.time;
    if time.fSliderPos == 0 && time.cSliderPos > 1
      time.fSliderPos = FMID;
      time.cSliderPos = time.cSliderPos - 2;
    elseif time.fSliderPos == FMAX && time.cSliderPos < CMAX-1
      time.fSliderPos = FMID;
      time.cSliderPos = time.cSliderPos + 2;
    end
    ShoMoData.time = time;

  case 'timestring'			% return string for displaying
					% .tview
    if ~ShoMoData.animating
      speed = 0;
    else
      speed = abs(ShoMoData.speed.speed);
    end
    tview = ShoMoData.tview;
    if speed > 1.4
      out = sprintf( '%.0f', tview );
    elseif speed > 0.14
      out = sprintf( '%.1f', tview );
    elseif speed > 0.014
      out = sprintf( '%.2f', tview );
    elseif speed > 0.0014 || ShoMoData.tmax >= 10
      out = sprintf( '%.3f', tview );
    else
      out = sprintf( '%.4f', tview );
    end

  case 'finefreq'			% return fine slider cycling
					% frequency
    speed = abs(ShoMoData.speed.speed);
    out = speed * CMAX / (ShoMoData.tmax - ShoMoData.tmin);

end
end


%----------


function  [h] = triangles( parent, vertices, faces, colour )

% TRIANGLES  make a patch consisting of one or more triangles
% h=triangles(parent,vertices,faces,colour)  creates a patch consisting of
% one or more triangles, and returns its handle.  Vertices is an Nx3 array
% of vertices, with N>=3.  Faces is an Mx3 array of vertex numbers such
% that each row defines one triangle.  Colour is an RGB colour vector
% defining the colour of the whole patch.  This function works out the
% vertex normal data on the assumption that the triangles are flat (i.e.,
% the patch represents part or all of a polygon or polyhedron), and
% duplicates vertices as necessary if they need to be associated with more
% than one normal.  To get the normals right, the vertices in each triangle
% must be listed in counter-clockwise order, as viewed from the 'outside'
% or 'top' face of the triangle.

% Note on tolerances: A lot of geometric data exists in single-precision
% format, so one should not assume that vertex data is always accurate to
% double precision.

Nv = size(vertices,1);			% number of vertices supplied
Nt = size(faces,1);			% number of triangles

if size(vertices,2) ~= 3 || Nv < 3
  error('vertices must be an Nx3 matrix, N>=3');
end

if size(faces,2) ~= 3
  error('faces must be an Mx3 array of vertex numbers')
end

if any(any( faces < 1 )) || any(any( faces > Nv ))
  error('faces contains at least one vertex number out of range')
end

if ~isvector(colour) || length(colour)~=3 || any(colour<0) || any(colour>1)
  error('colour must be an RGB triple');
end

% Step 1:  Calculate the normal for each triangle.

normals = zeros(Nt,3);

for i = 1:Nt
  v1 = vertices(faces(i,1),:);
  v2 = vertices(faces(i,2),:);
  v3 = vertices(faces(i,3),:);
  n = cross( v2-v1, v3-v1 );
  nmag = norm(n);
  if nmag == 0 || nmag < 1e-6 * max([norm(v2-v1) norm(v3-v1)])
    error('degenerate triangle on row %d', i);
  end
  normals(i,:) = n/nmag;
end

% Step 2:  Look for duplicate normals.  At the end of this step, the
% variable Nn contains the number of unique normals found, the first Nn
% rows of normals() contain the coordinates of those normals, and the
% variable normap contains the mapping from triangle index numbers to
% unique normal index numbers; i.e., the normal for triangle number i is
% normal number normap(i).

normap = 1:Nt;
cut = 0;
for i = 2:Nt
  for j = 1:i-1-cut
    if norm( normals(i,:) - normals(j,:) ) < 1e-6
      normap(i) = j;
      break
    end
  end
  if normap(i) ~= i			% found a duplicate
    cut = cut + 1;
  elseif cut > 0			% found a unique normal which
    normals(i-cut,:) = normals(i,:);	% needs to be copied forward
    normap(i) = i - cut;
  end
end

Nn = Nt - cut;				% number of unique normals

% Step 3:  Work out how many distinct vertex/normal pairs there are; and
% construct new arrays of unique vertex/normal pairs.  At the end of this
% step, Nvn is the number of unique vertex/normal pairs found, and vertnorm
% is a matrix that maps from supplied-vertex and unique-normal numbers to
% unique vertex/normal pair numbers.  Thus, for supplied-vertex number i in
% triangle j, the unique vertex/normal pair number is
% vertnorm(i,normap(j)), and is the correct row number to access the vertex
% and normal coordinates in uVerts and uNorms.

Nvn = 0;
vertnorm = zeros(Nv,Nn);

for i = 1:Nt
  for j = 1:3
    if vertnorm( faces(i,j), normap(i) ) == 0
      Nvn = Nvn + 1;
      vertnorm( faces(i,j), normap(i) ) = Nvn;
    end
  end
end

uVerts = zeros(Nvn,3);			% storage for unique vertex/normal
uNorms = zeros(Nvn,3);			% pair coordinates

for i = 1:Nv
  for j = 1:Nn
    if vertnorm(i,j) ~= 0
      uVerts(vertnorm(i,j),:) = vertices(i,:);
      uNorms(vertnorm(i,j),:) = normals(j,:);
    end
  end
end

% Step 4:  Map the face data from supplied-vertex numbers to unique
% vertex/normal pair numbers.

for i = 1:Nt
  faces(i,:) = vertnorm( faces(i,:), normap(i) );
end

% Step 5:  Make the patch.

h = patch( 'Parent', parent, ...
	   'Vertices', uVerts, ...
	   'VertexNormals', uNorms, ...
	   'Faces', faces, ...
	   'FaceColor', colour, ...
	   'EdgeColor', 'none', ...
	   'FaceLighting', 'gouraud', ...
	   'BackFaceLighting', 'unlit' );
end


%----------


function  updatepanel

% UPDATEPANEL  update appearance of ShowMotion control panel
% updatepanel  updates the appearance of the buttons, sliders and numeric
% strings in the ShowMotion control panel.  In every case, it compares the
% current actual appearance with what it is supposed to be, and makes
% changes only if they differ.  There are two special cases: during
% animation, the fine slider is set to zero (mid range) if the speed is
% above a threshold, and the numeric time string is only updated if a fixed
% minimum time has elapsed since the last update.

global ShoMoData;

if ~ishandle(ShoMoData.panel.fig)		% no panel, so do nothing
  return
end

  function  adjust_slider( handle, newpos )
    oldpos = get( handle, 'UserData' );
    if oldpos ~= newpos
      X = get( handle, 'XData' );
      set( handle, 'XData', X-oldpos+newpos, 'UserData', newpos );
    end
  end

panel = ShoMoData.panel;

if panel.playing ~= ShoMoData.animating
  panel.playing = ShoMoData.animating;
  if panel.playing
    set( panel.play, 'FaceColor', panel.orange );
  else
    set( panel.play, 'FaceColor', panel.red );
  end
  ShoMoData.panel.playing = panel.playing;
end

if panel.repeating ~= ShoMoData.autorepeat
  panel.repeating = ShoMoData.autorepeat;
  if panel.repeating
    set( panel.repeat, 'CData', panel.repeat_on );
  else
    set( panel.repeat, 'CData', panel.repeat_off );
  end
  ShoMoData.panel.repeating = panel.repeating;
end

s = ShoMoData.speed;

if panel.goingfwd ~= (s.sgn>0)
  panel.goingfwd = s.sgn > 0;
  if panel.goingfwd
    set( panel.direction, 'CData', panel.forward );
  else
    set( panel.direction, 'CData', panel.reverse );
  end
  ShoMoData.panel.goingfwd = panel.goingfwd;
end

adjust_slider( panel.speedSlider, s.sliderpos );

str = get( panel.speedDisplay, 'String' );
if ~strcmp( str, s.displaystring )
  set( panel.speedDisplay, 'String', s.displaystring );
end

t = ShoMoData.time;

adjust_slider( panel.coarseSlider, t.cSliderPos );

if ~ShoMoData.animating || timectrl('finefreq') <= 4
  adjust_slider( panel.fineSlider, t.fSliderPos );
else
  adjust_slider( panel.fineSlider, t.fineRange/2 );
end

if ShoMoData.animating
  treal = toc;
  if treal - panel.updated > 0.3
    ts = timectrl('timestring');
    str = get( panel.timeDisplay, 'String' );
    if ~strcmp( ts, str );
      set( panel.timeDisplay, 'String', ts );
      ShoMoData.panel.updated = treal;
    end
  end
else
  ts = timectrl('timestring');
  str = get( panel.timeDisplay, 'String' );
  if ~strcmp( ts, str );
    set( panel.timeDisplay, 'String', ts );
  end
  ShoMoData.panel.updated = -1;
end

end					% because there is a nested function


%----------


function  viewkeypan( right, up )

% VIEWKEYPAN  pan view of ShowMotion camera from keyboard
% viewkeypan(right,up) pans the view of a ShowMotion camera in response to
% keyboard commands.  The arguments take values of +1, -1 or 0, indicating
% positive, negative, or no movement in the indicated direction.

  global ShoMoData;

  panang = 0.015 * ShoMoData.view.angle;

  panvec = [ -up*panang; right*panang; 0 ];

  viewpan( panvec );
end


%----------


function  viewmousepan( new, old )

% VIEWMOUSEPAN  pan view of ShowMotion camera by mouse motion
% viewmousepan(new,old) pans the view of a ShowMotion camera in response to
% mouse cursor motion.  The arguments are the current and previous cursor
% positions expressed in window pixel coordinates.  The pan is calculated
% so that the scene point under the cursor tracks the cursor as it moves.

  old = mouseray(mousepos(old));
  new = mouseray(mousepos(new));

  panvec = cross(old,new);
  sinang = norm(panvec);
  if sinang ~= 0
    panvec = panvec * asin(sinang) / sinang;
  end

  viewpan( -panvec );
end


%----------


function  viewmouserot( new, old )

% VIEWMOUSEROT  rotate view of ShowMotion camera by mouse motion
% viewmouserot(new,old) implements the Featherstone crystal-ball view
% rotation algorithm, to rotate the view of a ShowMotion camera in response
% to mouse cursor motion.  The arguments are the current and previous cursor
% positions expressed in window pixel coordinates.  Rotation behaviour: if
% the cursor is off the crystal ball (which is assumed to be visible), then
% the scene rotates about the camera's viewing axis, otherwise the scene
% rotates as if you were manipulating a real crystal ball with your finger.

% A more accurate description: when the cursor is off the ball, the camera
% rotates about its viewing axis such that a ray passing from the rotation
% centre through the cursor's hot spot tracks the hot spot as it moves.  If
% the cursor is near the centre of the ball, then the camera orbits about
% an axis perpendicular to the plane defined by the rotation centre and the
% two points on the crystal ball under the new and old cursor positions.
% This creates the illusion that the cursor is touching the ball and
% rotating it.  If the cursor is near the edge of the ball then the
% rotation behaviour resembles the ball-centre behaviour, but is distorted
% in order to avoid an abrupt (and singular) transition to the off-ball
% behaviour.

  new = mousepos(new);
  old = mousepos(old);
  x = old(1);
  y = old(2);
  dx = new(1) - old(1);
  dy = new(2) - old(2);
  R = 0.8;				% radius of crystal ball
  R2 = R^2;
  r2 = x^2 + y^2;
  if r2 >= R2				% pointer outside crystal ball
    rz = (x*dy-y*dx)/r2;
    viewrotate( [0 0 rz] );
  else					% pointer inside crystal ball
    R3 = R2*(R+sqrt(R2-r2));
    rx = -x*y/R3*dx - (1/R-x*x/R3)*dy;
    ry = x*y/R3*dy + (1/R-y*y/R3)*dx;
    rz = (x*dy-y*dx)/R2;
    viewrotate( [rx ry rz] );
  end
end


%----------


function  viewpan( vec )

% VIEWPAN  pan view of ShowMotion camera
% viewpan( vec ) pans the view of a ShowMotion camera.  The argument is a
% 3D rotation vector specifying a rotation of the camera about its current
% position, expressed in camera coordinates.  The units are radians.

  global ShoMoData;

  vw = ShoMoData.view;

  vec = [vec(1); vec(2); vec(3)];	% make sure it's a column vector

  [X,Y,Z] = cameraxes;
  E = [X Y Z];				% camera -> scene coord xform
  vec = E * vec;

  R = rv(vec)';				% camera (column vec) rotation matrix
                                        % expressed in scene coords
  vw.focus = vw.campos + (vw.focus-vw.campos) * R';
  vw.upvec = vw.upvec * R';

  viewupdate( vw );
end


%----------


function  viewrefocus( mag )

% VIEWREFOCUS  move focus towards/away from ShowMotion camera
% viewrefocus( mag ) moves the target point of a ShowMotion camera towards
% or away from the camera.  This operation assumes that the crystal ball is
% visible, so that the ball can be seen to advance or recede.  (Note: the
% crystal ball automatically adjusts its size to occupy a constant fraction
% of the window, so the only way you can tell it is moving is by watching
% the intersections between the ball and other objects.)  The argument is a
% scalar close to 1: the camera--focus distance is adjusted to be 1/mag
% times its previous value.  This makes the meaning of mag comparable to
% the argument of zoom(mag).

  global ShoMoData;

  vw = ShoMoData.view;

  vw.focus = vw.campos + (vw.focus - vw.campos) / mag;

  viewupdate( vw );
end


%----------


function  viewreset

% VIEWRESET  (re)initialize ShowMotion camera view
% viewreset (re)initializes the ShowMotion camera and the data structure
% ShoMoData.view to an initial state which is partly predefined and partly
% a function of the camera properties specified in the model data structure
% argument supplied to showmotion.

  global ShoMoData;

  cam = ShoMoData.camera;

  view.on_hold = 0;
  view.angle = 25 * pi/180;
  view.upvec = cam.up;

  [X,Y,Z] = bounds;

  D = [ X(2)-X(1), Y(2)-Y(1), Z(2)-Z(1) ];
  r = norm(D) / 2;			% radius that must be captured
  d = r / sin( view.angle/2 );		% necessary distance to camera
  d = d / cam.zoom;			% adjustment for camera zoom

  % the following code works out where the track point is in scene
  % coordinates, and initializes camera.oldtrackpos accordingly.

  if cam.trackbody == 0
    trackpos = cam.trackpoint;
  else
    h = ShoMoData.handles(cam.trackbody);
    T = get( h, 'Matrix' );
    trackpos = [cam.trackpoint 1] * T';
    trackpos = trackpos(1:3);
  end

  ShoMoData.camera.oldtrackpos = trackpos;

  % This code works out the location of the view focus.  If no camera locus
  % has been specified then the focus is the centre of the bounding box
  % calculated earlier.  Otherwise, the focus is located such that the
  % track point appears at the specified locus in normalized window
  % coordinates.

  if length(cam.locus) == 0
    view.focus = [ mean(X), mean(Y), mean(Z) ];
  else
    ShoMoData.view = view;		% allows mouseray to work
    ray = mouseray( cam.locus );	% ray to trackpos in camera coords
    Z = cam.direction;
    Y = cam.up - Z * dot(Z,cam.up);
    Y = Y / norm(Y);
    X = cross( Y, Z );
    E = [X' Y' Z'];			% coord xfm camera --> scene coords
    ray = E * ray;
    view.focus = trackpos - d * (cam.direction + ray');
  end

  view.campos = view.focus + cam.direction * d;

  ShoMoData.view = view;

  set( ShoMoData.ax, ...
       'CameraPosition', view.campos, ...
       'CameraTarget', view.focus, ...
       'CameraUpVector', view.upvec, ...
       'CameraViewAngle', view.angle * 180/pi, ...
       'Projection', 'perspective' );

  adjustlighting;
  adjustball;
end


%----------


function  viewrotate( vec )

% VIEWROTATE  rotate view of ShowMotion camera
% viewrotate( vec ) rotates the view of a ShowMotion camera.  The argument
% is a rotation vector expressed in camera coordinates: x=right, y=up and
% z=towards the viewer.  Thus, if vec=[0.1 0 0] then the camera is rotated
% in such a manner that the objects in view appear to have rotated by 0.1
% radians about an axis pointing to the right and passing through the view
% centre.

  global ShoMoData;

  vw = ShoMoData.view;

  vec = [vec(1); vec(2); vec(3)];	% make sure it's a column vector

  [X,Y,Z] = cameraxes;
  E = [X Y Z];				% camera -> scene coord xform
  vec = E * vec;

  R = rv(vec)';				% scene (col vec) rotation operator
                                        % (therefore camera row vec rot op)
  vw.campos = vw.focus + (vw.campos-vw.focus) * R;
  vw.upvec = vw.upvec * R;

  viewupdate( vw );
end


%----------


function  viewtrack

% VIEWTRACK  make ShowMotion camera track point of interest
% viewtrack  translates the ShowMotion camera horizontally (as defined by
% camera.up) so as to follow the motion of the given track point in the
% scene.

  global ShoMoData;

  cam = ShoMoData.camera;

  if cam.trackbody == 0			% not a tracking camera
    return
  end

  h = ShoMoData.handles(cam.trackbody);
  T = get( h, 'Matrix' );
  newpos = [cam.trackpoint 1] * T';
  ShoMoData.camera.oldtrackpos = newpos(1:3);

  vw = ShoMoData.view;

  delta = newpos(1:3) - cam.oldtrackpos;
  delta = delta - dot(delta,cam.up)*cam.up;  % track horizontal component only

  vw.campos = vw.campos + delta;
  vw.focus = vw.focus + delta;

  viewupdate( vw );
end


%----------


function  viewupdate( view )

% VIEWUPDATE  update ShowMotion camera view
% viewupdate(view) stores the given viewing parameters in the data
% structure ShoMoData.view.  If there is no animation in progress, then it
% also updates the ShowMotion camera; otherwise it marks the new viewing
% parameters as 'on hold'.  If viewupdate is called with no argument, then
% it unconditionally updates the ShowMotion camera with any on-hold viewing
% parameters in ShoMoData.view.

  global ShoMoData;

  if nargin == 0
    view = ShoMoData.view;
    if view.on_hold
      update = 1;			% unconditional update
    else
      return				% nothing to do
    end
  else
    update = ~ShoMoData.animating;	% update only if not animating
  end

  view.on_hold = ~update;
  ShoMoData.view = view;

  if update
    set( ShoMoData.ax, ...
	 'CameraPosition', view.campos, ...
	 'CameraTarget', view.focus, ...
	 'CameraUpVector', view.upvec, ...
	 'CameraViewAngle', view.angle * 180/pi );
    adjustlighting;
    adjustball;
  end
end


%----------


function  viewzoom( mag )

% VIEWZOOM  zoom view of ShowMotion camera
% viewzoom( mag ) zooms the view of a ShowMotion camera by moving the
% camera towards or away from the target point.  The argument is a
% magnification factor: objects at the target point appear mag times bigger.

  global ShoMoData;

  vw = ShoMoData.view;

  vw.campos = vw.focus + (vw.campos - vw.focus) / mag;

  viewupdate( vw );
end
