function customSymFunction(obj, export_path, der_level)

if nargin < 3
    der_level = 1;
end

model = obj.Model;

initialize(model);

domain = obj.Gamma.Nodes.Domain{1};
for i=1:3
    compile(obj.Gamma.Nodes.Domain{i}, model);
end
% p[1] - deltaphip(qf) = 0
p1eq = SymFunction('Name', ['p1eq_sca']);
p1eq = setPreCommands(p1eq, ...
    ['Qe = GetQe[];',...
    'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
    ]);
p1eq = setExpression(p1eq,...
    [domain.PhaseVariable.Var.Dependents{1}.Symbols.Kin,' - p[1]']);
p1eq = setDepSymbols(p1eq,{'Qe','P'});
p1eq = setDescription(p1eq,'p[1] - deltaphip(q0) = 0');
export(p1eq, export_path, true, der_level);
obj.CustomSymFuncs.p1eq = p1eq;

p2eq = SymFunction('Name', ['p2eq_sca']);
p2eq = setPreCommands(p2eq, ...
    ['Qe = GetQe[];',...
    'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
    ]);
p2eq = setExpression(p2eq,...
    [domain.PhaseVariable.Var.Dependents{1}.Symbols.Kin,' - p[2]']);
p2eq = setDepSymbols(p2eq,{'Qe','P'});
p2eq = setDescription(p2eq,'p[2] - deltaphip(qf) = 0');
export(p2eq, export_path, true, der_level);
obj.CustomSymFuncs.p2eq = p2eq;

% impact toe velocity
impactToeVelocity = SymFunction('Name', ['impactToeVelocity_vec']);
impactToeVelocity = setPreCommands(impactToeVelocity, ...
    ['Qe = GetQe[]; dQe = D[Qe,t];']);
impactToeVelocity = setExpression(impactToeVelocity,...
    ['Join[',model.KinObjects.LeftToePosX.Symbols.Jac,...
    model.KinObjects.LeftToePosY.Symbols.Jac,...
    model.KinObjects.LeftToePosZ.Symbols.Jac,'].dQe']);
impactToeVelocity = setDepSymbols(impactToeVelocity,{'Qe','dQe'});
impactToeVelocity = setDescription(impactToeVelocity,'toe impact velocities in x,y,z directions');
export(impactToeVelocity, export_path, true, der_level);
obj.CustomSymFuncs.impactToeVelocity = impactToeVelocity;

impactHeelVelocity = SymFunction('Name', ['impactHeelVelocity_vec']);
impactHeelVelocity = setPreCommands(impactHeelVelocity, ...
    ['Qe = GetQe[]; dQe = D[Qe,t];']);
impactHeelVelocity = setExpression(impactHeelVelocity,...
    ['Join[',model.KinObjects.LeftHeelPosX.Symbols.Jac,...
    model.KinObjects.LeftHeelPosY.Symbols.Jac,...
    model.KinObjects.LeftHeelPosZ.Symbols.Jac,'].dQe']);
impactHeelVelocity = setDepSymbols(impactHeelVelocity,{'Qe','dQe'});
impactHeelVelocity = setDescription(impactHeelVelocity,'toe impact velocities in x,y,z directions');
export(impactHeelVelocity, export_path, true, der_level);
obj.CustomSymFuncs.impactHeelVelocity = impactHeelVelocity;

index = obj.Gamma.Nodes.Domain{1}.ActPositionOutput.getIndex('RightTorsoRoll');
kin_obj = obj.Gamma.Nodes.Domain{1}.ActPositionOutput.KinGroupTable(index).KinObj;
torsoRollBoundary = SymFunction('Name', ['torsoRollBoundary_sca']);
torsoRollBoundary = setPreCommands(torsoRollBoundary, ...
    ['Qe = GetQe[];']);
torsoRollBoundary = setExpression(torsoRollBoundary,...
    kin_obj.Symbols.Kin);
torsoRollBoundary = setDepSymbols(torsoRollBoundary,{'Qe'});
torsoRollBoundary = setDescription(torsoRollBoundary,'boundary constraints on right torso roll output');
export(torsoRollBoundary, export_path, true, der_level);
obj.CustomSymFuncs.torsoRollBoundary = torsoRollBoundary;

index = obj.Gamma.Nodes.Domain{2}.ActPositionOutput.getIndex('LeftLegRoll');
kin_obj = obj.Gamma.Nodes.Domain{2}.ActPositionOutput.KinGroupTable(index).KinObj;
legRollBoundary = SymFunction('Name', ['legRollBoundary_sca']);
legRollBoundary = setPreCommands(legRollBoundary, ...
    ['Qe = GetQe[];']);
legRollBoundary = setExpression(legRollBoundary,...
    kin_obj.Symbols.Kin);
legRollBoundary = setDepSymbols(legRollBoundary,{'Qe'});
legRollBoundary = setDescription(legRollBoundary,'boundary constraints on left leg roll output');
export(legRollBoundary, export_path, true, der_level);     

obj.CustomSymFuncs.legRollBoundary = legRollBoundary;


end