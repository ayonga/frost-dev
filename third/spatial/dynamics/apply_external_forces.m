function  f_out = apply_external_forces( parent, Xup, f_in, f_ext )

% apply_external_forces  subtract f_ext from a given cell array of forces
% f_out=apply_external_forces(parent,Xup,f_in,f_ext)  incorporates the
% external forces specified in f_ext into the calculations of a dynamics
% algorithm.  It does this by subtracting the contents of f_ext from an
% array of forces supplied by the calling function (f_in) and returning the
% result.  f_ext has the following format: (1) it must either be an empty
% cell array, indicating that there are no external forces, or else a cell
% array containing NB elements such that f_ext{i} is the external force
% acting on body i; (2) f_ext{i} must either be an empty array, indicating
% that there is no external force acting on body i, or else a spatial or
% planar vector (as appropriate) giving the external force expressed in
% absolute coordinates.  apply_external_forces performs the calculation
% f_out = f_in - transformed f_ext, where f_out and f_in are cell arrays of
% forces expressed in link coordinates; so f_ext has to be transformed to
% link coordinates before use.  The arguments parent and Xup contain the
% parent array and link-to-link coordinate transforms for the model to
% which the forces apply, and are used to work out the coordinate
% transforms.

% Note: the possibility exists to allow various formats for f_ext;
% e.g. 6/3xNB matrix, or structure with shortened cell array f_ext and a
% list of body numbers (f_ext{i} applies to body b(i))

f_out = f_in;

if length(f_ext) > 0
  for i = 1:length(parent)
    if parent(i) == 0
      Xa{i} = Xup{i};
    else
      Xa{i} = Xup{i} * Xa{parent(i)};
    end
    if length(f_ext{i}) > 0
      f_out{i} = f_out{i} - Xa{i}' \ f_ext{i};
    end
  end
end
