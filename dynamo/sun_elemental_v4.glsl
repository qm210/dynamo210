float _t_[8] = float[8](0.,43.910,177.244,178.253,179.423,180.710,182.077,196.061);
float _b_[8] = float[8](0.,72.,360.,362.,364.,366.,368.,388.);
float _fac_[8] = float[8](1.530,2.160,-0.207,-0.302,-0.466,-0.752,1.430,1.430);
float _slope_[8] = float[8](0.791,0.,-10.439,-6.008,-3.457,-1.989,0.,0.);
float _beat(in float t){float b=0.; int _it;
    for(_it = 0; _it < 6 && _t_[_it + 1] < t; _it++);
    if (_slope_[_it] == 0.) return _b_[_it] + (t - _t_[_it]) * _fac_[_it];
    return _b_[_it] + _fac_[_it] * (exp(_slope_[_it]*(t - _t_[_it])) - 1.);
}
