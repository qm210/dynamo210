
// dynamo210 beat/light sync GLSL function generator by QM (April 2021, corona fuck yeah)
// usage: get current beat by
// float b =_beat(iTime);
// depending on the nature of stuff, you might need a constant offset like iTime - 0.05, idk
// then call your curve functions with argument b

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
    float r = 0.;
    r += .8234 * pow(mod(b, 1.0), .0347) * exp(-3.4657*mod(b, 1.0));
    return r * theta(b);
}
float anfangsplingpling(float b)
{
    b -= 4.;
    if (b<0.) return 0.;
    float r = 0.;
    r += .25*smstep(0., .01, b);
    r += .25*smstep(0., .01, (b-.25));
    r += .25*smstep(0., .01, (b-.5));
    r += .25*smstep(0., .01, (b-.75));
    return r * theta(b);
}
float basiclead(float b)
{
    b -= 5.;
    if (b<0.) return 0.;
    if (b>12.) return 0.;
    b = mod(b, 2.);
    float r = 0.;
    r += theta(b) * (2.*smstep(-.01, .01, b)-1.)*(1.-smstep(0., .25, b-.01));
    r += theta((b-.125)) * (2.*smstep(-.01, .01, (b-.125))-1.)*(1.-smstep(0., .25, (b-.125)-.01));
    r += theta((b-.25)) * (2.*smstep(-.01, .01, (b-.25))-1.)*(1.-smstep(0., .25, (b-.25)-.01));
    r += theta((b-.5)) * (2.*smstep(-.01, .01, (b-.5))-1.)*(1.-smstep(0., .25, (b-.5)-.01));
    r += theta((b-.75)) * (2.*smstep(-.01, .01, (b-.75))-1.)*(1.-smstep(0., .25, (b-.75)-.01));
    r += theta((b-1.)) * (2.*smstep(-.01, .01, (b-1.))-1.)*(1.-smstep(0., .25, (b-1.)-.01));
    r += theta((b-1.125)) * (2.*smstep(-.01, .01, (b-1.125))-1.)*(1.-smstep(0., .25, (b-1.125)-.01));
    r += theta((b-1.25)) * (2.*smstep(-.01, .01, (b-1.25))-1.)*(1.-smstep(0., .25, (b-1.25)-.01));
    r += theta((b-1.5)) * (2.*smstep(-.01, .01, (b-1.5))-1.)*(1.-smstep(0., .25, (b-1.5)-.01));
    return r * theta(b);
}
float basiclead_18_to_26(float b)
{
    b -= 17.;
    if (b<0.) return 0.;
    if (b>8.) return 0.;
    b = mod(b, 2.);
    float r = 0.;
    r += theta(b) * (2.*smstep(-.01, .01, b)-1.)*(1.-smstep(0., .25, b-.01));
    r += theta((b-.125)) * (2.*smstep(-.01, .01, (b-.125))-1.)*(1.-smstep(0., .25, (b-.125)-.01));
    r += theta((b-.25)) * (2.*smstep(-.01, .01, (b-.25))-1.)*(1.-smstep(0., .25, (b-.25)-.01));
    r += theta((b-.5)) * (2.*smstep(-.01, .01, (b-.5))-1.)*(1.-smstep(0., .25, (b-.5)-.01));
    r += theta((b-.75)) * (2.*smstep(-.01, .01, (b-.75))-1.)*(1.-smstep(0., .25, (b-.75)-.01));
    r += theta((b-.875)) * (2.*smstep(-.01, .01, (b-.875))-1.)*(1.-smstep(0., .25, (b-.875)-.01));
    r += theta((b-1.125)) * (2.*smstep(-.01, .01, (b-1.125))-1.)*(1.-smstep(0., .25, (b-1.125)-.01));
    r += theta((b-1.25)) * (2.*smstep(-.01, .01, (b-1.25))-1.)*(1.-smstep(0., .25, (b-1.25)-.01));
    r += theta((b-1.375)) * (2.*smstep(-.01, .01, (b-1.375))-1.)*(1.-smstep(0., .25, (b-1.375)-.01));
    r += theta((b-1.5)) * (2.*smstep(-.01, .01, (b-1.5))-1.)*(1.-smstep(0., .25, (b-1.5)-.01));
    r += theta((b-1.625)) * (2.*smstep(-.01, .01, (b-1.625))-1.)*(1.-smstep(0., .25, (b-1.625)-.01));
    r += theta((b-1.75)) * (2.*smstep(-.01, .01, (b-1.75))-1.)*(1.-smstep(0., .25, (b-1.75)-.01));
    return r * theta(b);
}
float basiclead_27_to_35(float b)
{
    b -= 26.;
    if (b<0.) return 0.;
    if (b>8.) return 0.;
    float r = 0.;
    r += .8561 * pow(mod(b, 0.125), .0277) * exp(-2.7726*mod(b, 0.125));
    return r * theta(b);
}
float break1_51_to_53(float b)
{
    b -= 50.;
    if (b<0.) return 0.;
    if (b>2.) return 0.;
    float r = 0.;
    r += .4598 * pow(mod(b, 0.125), .1386) * exp(-13.8629*mod(b, 0.125));
    return r * theta(b);
}
float break2_51_to_53(float b)
{
    b -= 50.;
    if (b<0.) return 0.;
    float r = 0.;
    r += .2*.1433 * pow(mod(b, 0.167), .3466) * exp(-34.6574*mod(b, 0.167));
    return r * theta(b);
}
float basic_kick_10_to_26(float b)
{
    b -= 9.;
    if (b<0.) return 0.;
    if (b>16.) return 0.;
    b = mod(b, 4.);
    float r = 0.;
    r += theta(b) * (2.*smstep(-.01, .01, b)-1.)*(1.-smstep(0., .25, b-.01));
    r += theta((b-.375)) * (2.*smstep(-.01, .01, (b-.375))-1.)*(1.-smstep(0., .25, (b-.375)-.01));
    r += theta((b-.625)) * (2.*smstep(-.01, .01, (b-.625))-1.)*(1.-smstep(0., .25, (b-.625)-.01));
    r += theta((b-.75)) * (2.*smstep(-.01, .01, (b-.75))-1.)*(1.-smstep(0., .25, (b-.75)-.01));
    r += theta((b-1.)) * (2.*smstep(-.01, .01, (b-1.))-1.)*(1.-smstep(0., .25, (b-1.)-.01));
    r += theta((b-1.375)) * (2.*smstep(-.01, .01, (b-1.375))-1.)*(1.-smstep(0., .25, (b-1.375)-.01));
    r += theta((b-1.625)) * (2.*smstep(-.01, .01, (b-1.625))-1.)*(1.-smstep(0., .25, (b-1.625)-.01));
    r += theta((b-1.75)) * (2.*smstep(-.01, .01, (b-1.75))-1.)*(1.-smstep(0., .25, (b-1.75)-.01));
    r += theta((b-2.)) * (2.*smstep(-.01, .01, (b-2.))-1.)*(1.-smstep(0., .25, (b-2.)-.01));
    r += theta((b-2.375)) * (2.*smstep(-.01, .01, (b-2.375))-1.)*(1.-smstep(0., .25, (b-2.375)-.01));
    r += theta((b-2.7143)) * (2.*smstep(-.01, .01, (b-2.7143))-1.)*(1.-smstep(0., .25, (b-2.7143)-.01));
    r += theta((b-2.75)) * (2.*smstep(-.01, .01, (b-2.75))-1.)*(1.-smstep(0., .25, (b-2.75)-.01));
    r += theta((b-3.)) * (2.*smstep(-.01, .01, (b-3.))-1.)*(1.-smstep(0., .25, (b-3.)-.01));
    r += theta((b-3.25)) * (2.*smstep(-.01, .01, (b-3.25))-1.)*(1.-smstep(0., .25, (b-3.25)-.01));
    r += theta((b-3.5)) * (2.*smstep(-.01, .01, (b-3.5))-1.)*(1.-smstep(0., .25, (b-3.5)-.01));
    r += theta((b-3.75)) * (2.*smstep(-.01, .01, (b-3.75))-1.)*(1.-smstep(0., .25, (b-3.75)-.01));
    return r * theta(b);
}
float basic_clap_10_to_26(float b)
{
    b -= 9.;
    if (b<0.) return 0.;
    if (b>16.) return 0.;
    b = mod(b, 4.);
    float r = 0.;
    r += .1433 * pow((b-.25), .3466) * exp(-34.6574*(b-.25));
    r += .1*.1433 * pow((b-.6875), .3466) * exp(-34.6574*(b-.6875));
    r += .1433 * pow((b-.75), .3466) * exp(-34.6574*(b-.75));
    r += .1*.1433 * pow((b-.8125), .3466) * exp(-34.6574*(b-.8125));
    r += .1433 * pow((b-1.25), .3466) * exp(-34.6574*(b-1.25));
    r += .1*.1433 * pow((b-1.6875), .3466) * exp(-34.6574*(b-1.6875));
    r += .1433 * pow((b-1.75), .3466) * exp(-34.6574*(b-1.75));
    r += .1*.1433 * pow((b-1.8125), .3466) * exp(-34.6574*(b-1.8125));
    r += .1433 * pow((b-2.25), .3466) * exp(-34.6574*(b-2.25));
    r += .1*.1433 * pow((b-2.6875), .3466) * exp(-34.6574*(b-2.6875));
    r += .1433 * pow((b-2.75), .3466) * exp(-34.6574*(b-2.75));
    r += .1*.1433 * pow((b-2.8125), .3466) * exp(-34.6574*(b-2.8125));
    r += .1433 * pow((b-3.25), .3466) * exp(-34.6574*(b-3.25));
    r += .1*.1433 * pow((b-3.3125), .3466) * exp(-34.6574*(b-3.3125));
    r += .4*.1433 * pow((b-3.4375), .3466) * exp(-34.6574*(b-3.4375));
    r += .1*.1433 * pow((b-3.5), .3466) * exp(-34.6574*(b-3.5));
    r += .4*.1433 * pow((b-3.625), .3466) * exp(-34.6574*(b-3.625));
    r += .1*.1433 * pow((b-3.6875), .3466) * exp(-34.6574*(b-3.6875));
    r += .1433 * pow((b-3.75), .3466) * exp(-34.6574*(b-3.75));
    r += .1*.1433 * pow((b-3.8125), .3466) * exp(-34.6574*(b-3.8125));
    r += .3*.1433 * pow((b-3.875), .3466) * exp(-34.6574*(b-3.875));
    r += .05*.1433 * pow((b-3.9375), .3466) * exp(-34.6574*(b-3.9375));
    return r * theta(b);
}
float dancebeat_27_to_51(float b)
{
    b -= 26.;
    if (b<0.) return 0.;
    if (b>24.) return 0.;
    float r = 0.;
    r += .6*.8561 * pow(mod(b, 0.5), .0277) * exp(-2.7726*mod(b, 0.5));
    r += .8561 * pow(mod((b-.25), 0.5), .0277) * exp(-2.7726*mod((b-.25), 0.5));
    return r * theta(b);
}
float dancebeat2_53_to_71(float b)
{
    b -= 52.;
    if (b<0.) return 0.;
    if (b>18.) return 0.;
    b = mod(b, 4.);
    float r = 0.;
    r += .7*.8561 * pow(b, .0277) * exp(-2.7726*b);
    r += .8561 * pow((b-.25), .0277) * exp(-2.7726*(b-.25));
    r += .7*.8561 * pow((b-.5), .0277) * exp(-2.7726*(b-.5));
    r += .8561 * pow((b-.75), .0277) * exp(-2.7726*(b-.75));
    r += .7*.8561 * pow((b-1.), .0277) * exp(-2.7726*(b-1.));
    r += .8561 * pow((b-1.25), .0277) * exp(-2.7726*(b-1.25));
    r += .4*.8561 * pow((b-1.4375), .0277) * exp(-2.7726*(b-1.4375));
    r += .7*.8561 * pow((b-1.5), .0277) * exp(-2.7726*(b-1.5));
    r += .5*.8561 * pow((b-1.625), .0277) * exp(-2.7726*(b-1.625));
    r += .3*.4598 * pow((b-1.6875), .1386) * exp(-13.8629*(b-1.6875));
    r += .8561 * pow((b-1.75), .0277) * exp(-2.7726*(b-1.75));
    r += .4*.2739 * pow((b-1.8125), .231) * exp(-23.1049*(b-1.8125));
    r += .2*.2739 * pow((b-1.875), .231) * exp(-23.1049*(b-1.875));
    r += .1*.2739 * pow((b-1.9375), .231) * exp(-23.1049*(b-1.9375));
    r += .8*.8561 * pow((b-2.), .0277) * exp(-2.7726*(b-2.));
    r += .6*.8561 * pow((b-2.125), .0277) * exp(-2.7726*(b-2.125));
    r += .8561 * pow((b-2.25), .0277) * exp(-2.7726*(b-2.25));
    r += .8561 * pow((b-2.375), .0277) * exp(-2.7726*(b-2.375));
    r += .8561 * pow((b-2.625), .0277) * exp(-2.7726*(b-2.625));
    r += .8561 * pow((b-2.75), .0277) * exp(-2.7726*(b-2.75));
    r += .8561 * pow((b-3.), .0277) * exp(-2.7726*(b-3.));
    r += .8561 * pow((b-3.25), .0277) * exp(-2.7726*(b-3.25));
    r += .6*.8561 * pow((b-3.375), .0277) * exp(-2.7726*(b-3.375));
    r += .8561 * pow((b-3.5), .0277) * exp(-2.7726*(b-3.5));
    r += .8*.8561 * pow((b-3.75), .0277) * exp(-2.7726*(b-3.75));
    return r * theta(b);
}
float dancebeat_75_to_91(float b)
{
    b -= 74.;
    if (b<0.) return 0.;
    if (b>16.) return 0.;
    float r = 0.;
    r += .6*.8561 * pow(mod(b, 0.5), .0277) * exp(-2.7726*mod(b, 0.5));
    r += .8561 * pow(mod((b-.25), 0.5), .0277) * exp(-2.7726*mod((b-.25), 0.5));
    return r * theta(b);
}
float dancelead_35_to_51(float b)
{
    b -= 34.;
    if (b<0.) return 0.;
    if (b>16.) return 0.;
    float r = 0.;
    r += .7*.8561 * pow(b, .0277) * exp(-2.7726*b);
    r += .8*.8561 * pow((b-.375), .0277) * exp(-2.7726*(b-.375));
    r += .9*.8561 * pow((b-1.), .0277) * exp(-2.7726*(b-1.));
    r += .6*.8561 * pow((b-1.375), .0277) * exp(-2.7726*(b-1.375));
    r += .8*.8561 * pow((b-1.625), .0277) * exp(-2.7726*(b-1.625));
    r += .8561 * pow((b-2.), .0277) * exp(-2.7726*(b-2.));
    r += .9*.8561 * pow((b-2.75), .0277) * exp(-2.7726*(b-2.75));
    r += .7*.8561 * pow((b-3.25), .0277) * exp(-2.7726*(b-3.25));
    r += .5*.8561 * pow((b-3.5), .0277) * exp(-2.7726*(b-3.5));
    r += .6*.8561 * pow((b-3.75), .0277) * exp(-2.7726*(b-3.75));
    return r * theta(b);
}
float complexlead_55_to_71(float b)
{
    b -= 54.;
    if (b<0.) return 0.;
    if (b>16.) return 0.;
    b = mod(b, 8.);
    float r = 0.;
    r += .4048 * pow(b, .3466) * exp(-1.7329*b);
    r += .4048 * pow((b-.625), .3466) * exp(-1.7329*(b-.625));
    r += .4048 * pow((b-1.25), .3466) * exp(-1.7329*(b-1.25));
    r += .4048 * pow((b-1.5), .3466) * exp(-1.7329*(b-1.5));
    r += .4048 * pow((b-2.), .3466) * exp(-1.7329*(b-2.));
    r += .4048 * pow((b-2.5), .3466) * exp(-1.7329*(b-2.5));
    r += .4048 * pow((b-3.), .3466) * exp(-1.7329*(b-3.));
    r += .9*.4048 * pow((b-4.), .3466) * exp(-1.7329*(b-4.));
    r += .4048 * pow((b-4.125), .3466) * exp(-1.7329*(b-4.125));
    r += .8*.4048 * pow((b-4.75), .3466) * exp(-1.7329*(b-4.75));
    r += .4048 * pow((b-5.), .3466) * exp(-1.7329*(b-5.));
    r += .4048 * pow((b-6.), .3466) * exp(-1.7329*(b-6.));
    r += .4048 * pow((b-7.), .3466) * exp(-1.7329*(b-7.));
    return r * theta(b);
}
float complexbass_55_to_71(float b)
{
    b -= 54.;
    if (b<0.) return 0.;
    if (b>16.) return 0.;
    b = mod(b, 8.);
    float r = 0.;
    r += .9526 * pow(b, .0087) * exp(-.8664*b);
    r += .9526 * pow((b-.125), .0087) * exp(-.8664*(b-.125));
    r += .9526 * pow((b-.375), .0087) * exp(-.8664*(b-.375));
    r += .9526 * pow((b-.625), .0087) * exp(-.8664*(b-.625));
    r += .9526 * pow((b-.875), .0087) * exp(-.8664*(b-.875));
    r += .9526 * pow((b-1.), .0087) * exp(-.8664*(b-1.));
    r += .9526 * pow((b-1.125), .0087) * exp(-.8664*(b-1.125));
    r += .9526 * pow((b-1.25), .0087) * exp(-.8664*(b-1.25));
    r += .9526 * pow((b-1.375), .0087) * exp(-.8664*(b-1.375));
    r += .9526 * pow((b-1.5), .0087) * exp(-.8664*(b-1.5));
    r += .9526 * pow((b-1.75), .0087) * exp(-.8664*(b-1.75));
    r += .9526 * pow((b-2.25), .0087) * exp(-.8664*(b-2.25));
    r += .9526 * pow((b-2.5), .0087) * exp(-.8664*(b-2.5));
    r += .9526 * pow((b-2.625), .0087) * exp(-.8664*(b-2.625));
    r += .9526 * pow((b-2.875), .0087) * exp(-.8664*(b-2.875));
    r += .9526 * pow((b-3.), .0087) * exp(-.8664*(b-3.));
    r += .9526 * pow((b-3.125), .0087) * exp(-.8664*(b-3.125));
    r += .9526 * pow((b-3.25), .0087) * exp(-.8664*(b-3.25));
    r += .9526 * pow((b-3.5), .0087) * exp(-.8664*(b-3.5));
    r += .9526 * pow((b-3.625), .0087) * exp(-.8664*(b-3.625));
    r += .9526 * pow((b-3.75), .0087) * exp(-.8664*(b-3.75));
    r += .9526 * pow((b-3.875), .0087) * exp(-.8664*(b-3.875));
    r += .9526 * pow((b-4.), .0087) * exp(-.8664*(b-4.));
    r += .9526 * pow((b-4.125), .0087) * exp(-.8664*(b-4.125));
    r += .9526 * pow((b-4.375), .0087) * exp(-.8664*(b-4.375));
    r += .4*.9526 * pow((b-4.625), .0087) * exp(-.8664*(b-4.625));
    r += .5*.9526 * pow((b-4.875), .0087) * exp(-.8664*(b-4.875));
    r += .6*.9526 * pow((b-5.), .0087) * exp(-.8664*(b-5.));
    r += .7*.9526 * pow((b-5.125), .0087) * exp(-.8664*(b-5.125));
    r += .8*.9526 * pow((b-5.25), .0087) * exp(-.8664*(b-5.25));
    r += .9*.9526 * pow((b-5.375), .0087) * exp(-.8664*(b-5.375));
    r += .9526 * pow((b-5.5), .0087) * exp(-.8664*(b-5.5));
    r += .7*.9526 * pow((b-5.875), .0087) * exp(-.8664*(b-5.875));
    r += .8*.9526 * pow((b-6.), .0087) * exp(-.8664*(b-6.));
    r += .9526 * pow((b-6.25), .0087) * exp(-.8664*(b-6.25));
    r += .9526 * pow((b-6.375), .0087) * exp(-.8664*(b-6.375));
    r += .9526 * pow((b-6.5), .0087) * exp(-.8664*(b-6.5));
    r += .9526 * pow((b-6.625), .0087) * exp(-.8664*(b-6.625));
    r += .6*.9526 * pow((b-6.875), .0087) * exp(-.8664*(b-6.875));
    r += .9526 * pow((b-7.), .0087) * exp(-.8664*(b-7.));
    r += .9526 * pow((b-7.375), .0087) * exp(-.8664*(b-7.375));
    return r * theta(b);
}
float drumfill_71_to_75(float b)
{
    b -= 70.;
    if (b<0.) return 0.;
    if (b>4.) return 0.;
    float r = 0.;
    r += .4*.8785 * pow(b, .0231) * exp(-2.3105*b);
    r += .4*.8785 * pow((b-1.), .0231) * exp(-2.3105*(b-1.));
    r += .4*.8785 * pow((b-2.), .0231) * exp(-2.3105*(b-2.));
    r += .6*.8785 * pow((b-3.), .0231) * exp(-2.3105*(b-3.));
    r += .8785 * pow((b-3.25), .0231) * exp(-2.3105*(b-3.25));
    r += .7*.8785 * pow((b-3.375), .0231) * exp(-2.3105*(b-3.375));
    r += .7*.8785 * pow((b-3.625), .0231) * exp(-2.3105*(b-3.625));
    r += .8785 * pow((b-3.75), .0231) * exp(-2.3105*(b-3.75));
    return r * theta(b);
}
float evol1(float b)
{
    if (b<0.) return 0.;
    float r = 0.;
    return r * theta(b);
}
float backgroundlead1(float b) {return basiclead(b-53.);}
float backgroundlead2(float b) {return basiclead(b-61.);}
float dancelead_75_to_91(float b) {return dancelead_35_to_51(b-40.);}