
// dynamo210 beat/light sync GLSL function generator by QM (April 2021, corona fuck yeah)
// usage: get current beat by
// float B =_beat(iTime);
// depending on the nature of stuff, you might need a constant offset like iTime - 0.05, idk
// then call your curve functions with argument B

float smstep(float a, float b, float x) {return smoothstep(a, b, clamp(x, a, b));}
float theta(float x) { return smstep(0.,1e-3,x); }
float _t_[24] = float[24](0.,3.2603,6.4331,9.5177,12.5141,15.4218,18.241,20.9719,23.6147,26.17,28.6384,31.0207,33.3179,35.5309,37.6611,39.7099,41.6785,43.5687,176.902,177.9116,179.0813,180.3687,181.7357,195.7194);
float _b_[24] = float[24](0.,1.,2.,3.,4.,5.,6.,7.,8.,9.,10.,11.,12.,13.,14.,15.,16.,17.,89.,89.5,90.,90.5,91.,96.);
float _fac_[24] = float[24](36.869,35.6266,34.4546,33.3708,32.3337,31.3744,30.4479,29.6029,28.7988,28.0326,27.3172,26.6472,26.0117,25.421,24.8597,24.3324,23.8371,.54,-3.1036,-4.5244,-6.9935,-11.2861,.3576,.3576);
float _slope_[24] = float[24](.0082,.0087,.0093,.0099,.0105,.0111,.0118,.0126,.0134,.0142,.0151,.016,.017,.0181,.0192,.0205,.0217,0.,-0.174,-0.1001,-0.0576,-0.0332,0.,0.);
float _beat(float t)
{
    int it; for(it = 0; it < 23 && _t_[it + 1] < t; it++);
    if (_slope_[it] == 0.) return _b_[it] + (t - _t_[it]) * _fac_[it];
    return _b_[it] + _fac_[it] * (exp(_slope_[it]*(t - _t_[it])) - 1.);
}
float ONCE_A_BEAT(float b)
{
    if (b<0.) return 0.;
    if (b>1.) return 0.;
    float r = 0.;
    r += .8234 * pow(mod(b, 1.0), .0347) * exp(-3.4657*mod(b, 1.0));
    return r * theta(b);
}
float anfangsplingpling(float b)
{
    b -= 4.;
    if (b<0.) return 0.;
    float r = 0.;
    r += .8561 * pow(b, .0277) * exp(-2.7726*b);
    r += .8561 * pow((b-.25), .0277) * exp(-2.7726*(b-.25));
    r += .8561 * pow((b-.5), .0277) * exp(-2.7726*(b-.5));
    r += .8561 * pow((b-.75), .0277) * exp(-2.7726*(b-.75));
    return r * theta(b);
}
float basiclead(float b)
{
    b -= 5.;
    if (b<0.) return 0.;
    b = mod(b, 2.);
    float r = 0.;
    r += .8561 * pow(b, .0277) * exp(-2.7726*b);
    r += .8561 * pow((b-.125), .0277) * exp(-2.7726*(b-.125));
    r += .8561 * pow((b-.25), .0277) * exp(-2.7726*(b-.25));
    r += .8561 * pow((b-.5), .0277) * exp(-2.7726*(b-.5));
    r += .8561 * pow((b-.75), .0277) * exp(-2.7726*(b-.75));
    r += .8561 * pow((b-1.), .0277) * exp(-2.7726*(b-1.));
    r += .8561 * pow((b-1.125), .0277) * exp(-2.7726*(b-1.125));
    r += .8561 * pow((b-1.25), .0277) * exp(-2.7726*(b-1.25));
    r += .8561 * pow((b-1.5), .0277) * exp(-2.7726*(b-1.5));
    return r * theta(b);
}