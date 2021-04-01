
// dynamo210 beat/light sync GLSL function generator by QM (April 2021, corona fuck yeah)
// usage: get current beat by
// float B =_beat(iTime);
// depending on the nature of stuff, you might need a constant offset like iTime - 0.05, idk
// then call your curve functions with argument B

float smstep(float a, float b, float x) {return smoothstep(a, b, clamp(x, a, b));}
float theta(float x) { return smstep(0.,1e-3,x); }
float _t_[8] = float[8](0.,43.910,177.244,178.253,179.423,180.710,182.077,196.061);
float _b_[8] = float[8](0.,72.,360.,362.,364.,366.,368.,388.);
float _fac_[8] = float[8](91.797,2.160,-12.414,-18.098,-27.974,-45.144,1.430,1.430); // fac is bps for flat segments, else... something else.
float _slope_[8] = float[8](0.013,0.,-0.174,-0.100,-0.058,-0.033,0.,0.);
float _beat(float t)
{
    int it; for(it = 0; it < 7 && _t_[it + 1] < t; it++);
    if (_slope_[it] == 0.) return _b_[it] + (t - _t_[it]) * _fac_[it];
    return _b_[it] + _fac_[it] * (exp(_slope_[it]*(t - _t_[it])) - 1.);
}
float FOUR_ON_FLOOR(float b)
{
    float r = 0.;
    r += 0.909 * pow(mod(b, 0.25), 0.029) * exp(-0.289*mod(b, 0.25));
    return r * theta(b);
}