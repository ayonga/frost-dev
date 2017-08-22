addpath('./spatial_v2/');
spatial_v2_init();
[model] = body_struct_to_spatial_model(robot);
model.parent(1) = 0;