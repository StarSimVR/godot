#include "GDMath.h"
#include <ellipse.hpp>

using namespace godot;

GDMath::GDMath() {
}

GDMath::~GDMath() {
	delete ellipse;
}

void GDMath::_register_methods() {
    register_method("_process", &GDMath::_process);
    register_property<GDMath, float>("r", &GDMath::r, 1.0);
	register_property<GDMath, float>("e", &GDMath::e, 1.0);
    register_property<GDMath, float>("speed", &GDMath::set_speed, &GDMath::get_speed, 1.0);
}

void GDMath::_init() {
    // initialize any variables here
    time_passed = 0.0;
	speed = 1.0;
    r = e = last_r = last_e = 1.0;
	ellipse = new Ellipse(r, e, 1, 1, 1, 1, 1, 1, 1, 1, 1);
}

void GDMath::_process(float delta) {
    time_passed += speed * delta;
	if (r != last_r || e != last_e) {
		last_r = r;
		last_e = e;
		delete ellipse;
		ellipse = new Ellipse(r, e, 1, 1, 1, 1, 1, 1, 1, 1, 1);
	}
	
	vector<float> v = ellipse->eval(time_passed);
	Vector3 new_position = Vector3(v[0], v[1], v[2]);

    set_translation(new_position);
}

void GDMath::set_speed(float p_speed) {
    speed = p_speed;
}

float GDMath::get_speed() {
    return speed;
}