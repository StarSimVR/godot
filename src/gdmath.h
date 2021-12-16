#ifndef GDMATH_H
#define GDMATH_H

#include <Godot.hpp>
#include <Spatial.hpp>
#include <ellipse.hpp>

namespace godot {

class GDMath : public Spatial {
    GODOT_CLASS(GDMath, Spatial)

private:
    float time_passed;
	float speed;
    float r, e;
	float last_r, last_e;
	Ellipse* ellipse;

public:
    static void _register_methods();

    GDMath();
    ~GDMath();

    void _init();
    void _process(float delta);
    void set_speed(float p_speed);
    float get_speed();
};

}

#endif