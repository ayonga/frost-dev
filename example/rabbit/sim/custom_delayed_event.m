function value = custom_delayed_event(obj, model, val, dep_vals, t, t0)

if (t - t0) < 0.1
    value = ones(size(val));
else
    value = val;
end

end