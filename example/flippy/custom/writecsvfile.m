function writecsvfile(result,n_output,nparam)

r = reshape(result(2:end),[n_output,nparam]);
r = [result(1),zeros(1,nparam-1);r];

csvwrite('/home/shishirny/repos/simulation/paramfile.csv',r);
end