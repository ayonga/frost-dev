function fcn = dbezier(coeff,s)

  dcoeff = diff_coeff(coeff);
	fcn = bezier(dcoeff,s);