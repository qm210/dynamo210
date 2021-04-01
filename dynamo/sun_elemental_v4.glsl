
// dynamo210 beat/light sync GLSL function generator by QM (April 2021, corona fuck yeah)
// usage: get current beat by
// float B =_beat(iTime);
// depending on the nature of stuff, you might need a constant offset like iTime - 0.05, idk
// then call your curve functions with argument B

float smstep(float a, float b, float x) {return smoothstep(a, b, clamp(x, a, b));}
float theta(float x) { return smstep(0.,1e-3,x); }
float _t_[10] = float[10](0.0000,25.8494,35.1844,43.1978,176.5312,177.5408,178.7104,179.9979,181.3648,195.3485);
float _b_[10] = float[10](0.0000,36.0000,52.0000,68.0000,356.0000,358.0000,360.0000,362.0000,364.0000,384.0000);
float _fac_[10] = float[10](114.1664,102.1082,92.5939,2.1600,-12.4144,-18.0975,-27.9740,-45.1443,1.4302,1.4302); // fac is bps for flat segments, else... something else.
float _slope_[10] = float[10](0.0106,0.0156,0.0199,0.0000,-0.1740,-0.1001,-0.0576,-0.0332,0.0000,0.0000);
float _beat(float t)
{
    int it; for(it = 0; it < 9 && _t_[it + 1] < t; it++);
    if (_slope_[it] == 0.) return _b_[it] + (t - _t_[it]) * _fac_[it];
    return _b_[it] + _fac_[it] * (exp(_slope_[it]*(t - _t_[it])) - 1.);
}
float FOUR_ON_FLOOR(float b)
{
    float r = 0.0000;
    r += 0.9944 * pow(mod(b, 1.0), 0.0010) * exp(-0.1000*mod(b, 1.0));
    return r * theta(b);
}