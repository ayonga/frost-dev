function f = calcDriftVector(obj, q, dq)

ddq = zeros(obj.Dimension,1);

f = obj.inverseDynamics(q,dq,ddq);

end