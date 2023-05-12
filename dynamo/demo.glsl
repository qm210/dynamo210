
// dynamo210 beat/light sync GLSL function generator by QM (April 2021, corona fuck yeah)
// usage: get current beat by
// float b =_beat(iTime);
// depending on the nature of stuff, you might need a constant offset like iTime - 0.05, idk
// then call your curve functions with argument b

float smstep(float a, float b, float x) {return smoothstep(a, b, clamp(x, a, b));}
float theta(float x) { return smstep(0.,1e-3,x); }

pub const DYNAMO: garlic_dynamo::Dynamo = garlic_dynamo::Dynamo {
    times: [0.,20.],
    beats: [0.,10.],
    factors: [0.5,0.5],
    slopes: [0.,0.],
};

float FOUR_ON_FLOOR(float b)
{
    float r = 0.;
    if (b<0.) return r;
    r += .9932 * pow(mod(b, 1.0), .0009) * exp(-.8664*mod(b, 1.0));
    return r * theta(b);
}