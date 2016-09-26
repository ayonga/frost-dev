function fcn = d2bezier(coeff,s)

	dcoeff = diff_coeff(coeff);
	d2coeff = diff_coeff(dcoeff); 
	
	fcn = bezier(d2coeff,s);