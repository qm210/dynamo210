
float smstep(float a, float b, float x) {return smoothstep(a, b, clamp(x, a, b));}'
float theta(float x) { return smstep(0.,1e-3,x); }
float _t_[8] = float[8](0.,43.910,177.244,178.253,179.423,180.710,182.077,196.061);
float _b_[8] = float[8](0.,72.,360.,362.,364.,366.,368.,388.);
float _fac_[8] = float[8](1.530,2.160,-0.207,-0.302,-0.466,-0.752,1.430,1.430);
float _slope_[8] = float[8](0.791,0.,-10.439,-6.008,-3.457,-1.989,0.,0.);
float _beat(float t)
{
    int it; for(it = 0; it < 6 && _t_[it + 1] < t; it++);
    if (_slope_[it] == 0.) return _b_[it] + (t - _t_[it]) * _fac_[it];
    return _b_[it] + _fac_[it] * (exp(_slope_[it]*(t - _t_[it])) - 1.);
}
float ONCE_PER_BEAT(float b)
{
    float r = 0.;
    r += 0.909 * pow(b, 0.029) * exp(-0.289*b);
    return r * theta(b-4.);
}
