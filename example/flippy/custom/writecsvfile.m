function writecsvfile(result,n_output)

r = reshape(result(2:end),[n_output,5]);
r = [result(1),zeros(1,4);r];

csvwrite('/home/shishirny/repos/simulation/paramfile.csv',r);
end