math('quit')

pause(1)

math('$Version')

math('N[EulerGamma,40]')

math('Integrate[Log[x]^(3/2),x]')

math('InputForm[Integrate[Log[x]^(3/2),x]]')

math('matlab2math', 'hilbert',hilb(20))

math('{Dimensions[hilbert],Det[hilbert]}')

math('exactHilbert = Table[1/(i+j-1),{i,20},{j,20}];')

math('Det[exactHilbert]')

math('N[Det[exactHilbert], 40]')

math('invHilbert = Inverse[hilbert];')

hilbert=math('math2matlab', 'invHilbert');
diag(hilbert)

disp('Passing and retrieving a scalar')
math('a=2')
b=3;
math('matlab2math','b',b)
math('b')
math('b[[1,1]]')
aa=math('math2matlab','{{a}}')


math('quit')

