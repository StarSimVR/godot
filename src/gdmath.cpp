#include "GDMath.h"
#include <ellipse.hpp>

using namespace godot;

GDMath::GDMath() {
}

GDMath::~GDMath() {
    // add your cleanup here
}

void GDMath::_register_methods() {
    register_method("_process", &GDMath::_process);
    register_property<GDMath, float>("r", &GDMath::r, 1.0);
	register_property<GDMath, float>("e", &GDMath::e, 1.0);
    register_property<GDMath, float>("speed", &GDMath::set_speed, &GDMath::get_speed, 1.0);
	
	register_signal<GDMath>("position_changed", "node", GODOT_VARIANT_TYPE_OBJECT, "new_pos", GODOT_VARIANT_TYPE_VECTOR3);
}

void GDMath::_init() {
    // initialize any variables here
    time_passed = 0.0;
	time_emit = 0.0;
    r = 1.0;
	e = 1.0;
    speed = 1.0;
}

void GDMath::_process(float delta) {
    time_passed += speed * delta;
	
    /*Vector2 new_position = Vector2(
        amplitude + (amplitude * sin(time_passed * 2.0)),
        amplitude + (amplitude * cos(time_passed * 1.5))
    );*/
	ellipse = new Ellipse(r, e, 1, 1, 1, 1, 1, 1, 1, 1, 1);
	vector<float> v = ellipse->eval(time_passed);
	Vector3 new_position = Vector3(v[0], v[1], v[2]);

    set_translation(new_position);

    time_emit += delta;
    if (time_emit > 1.0) {
        emit_signal("position_changed", this, Vector3(100 + v[0], 100 + v[1], 100 + v[2]));
		//emit_signal("position_changed", this, Vector3(ellipse->x(time_passed), ellipse->y(time_passed), ellipse->z(time_passed)));
		//emit_signal("position_changed", this, Vector3(15 * std :: cos (time_passed), 10 * std :: sin (time_passed), 0));

        time_emit = 0.0;
    }
}

void GDMath::set_speed(float p_speed) {
    speed = p_speed;
}

float GDMath::get_speed() {
    return speed;
}