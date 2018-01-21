Begin nlp051 NLP

* Printing
	Major print level 	1 		* 1/line major iteration log
	Minor print level 	1000    * 1000/line minor iteration log
	Solution 			Yes 	* on the Print file

* Hessian approximation
	Hessian 			limited memory
	Hessian updates 	10

* Scaling
    Scale option        1       * Attempt to scale to 1.0 among matrix coeff.
    Scale tolerance     0.9     *

* Convergence Tolerances
	Major feasibility tolerance 	1.0e-5 		* target nonlinear constraint violation
	Major optimality tolerance 		1.0e-5 		* target complementarity gap
	Minor feasibility tolerance 	1.0e-4 		* for satisfying the QP bounds

* SQP Method
	Time limit					0
    Iterations limit            500000
	Major iterations limit 		30
	Minor iterations limit		500000

* QP subproblems
    QPSolver            Cholesky    * Cholesky is default
    Elastic weight      1.0e+2      * used only during elastic mode
    Partial price       10          * 10 for large LPs

End   nlp051 NLP