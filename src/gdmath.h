#ifndef GDMATH_H
#define GDMATH_H

#include <Godot.hpp>
#include <Spatial.hpp>
#include <Engine.hpp>
#include <ellipse.hpp>

#define GDMATH_DEFAULT_SPEED 1.0
#define GDMATH_DEFAULT_RADIUS 1.0
#define GDMATH_DEFAULT_ECCENTRICITY 1.0
#define GDMATH_DEFAULT_CENTER Vector3(1.0, 1.0, 1.0)
#define GDMATH_DEFAULT_NORMAL Vector3(1.0, 1.0, 1.0)
#define GDMATH_DEFAULT_TANGENT Vector3(1.0, 1.0, 1.0)

namespace godot {

class GDMath : public Spatial {
	GODOT_CLASS(GDMath, Spatial)

private:
	Ellipse* ellipse;
	float time_passed;
	bool is_ready;
	
	float speed;
	float radius, eccentricity;
	Vector3 center, normal, tangent;
public:
	static void _register_methods();

	GDMath();
	~GDMath();

	void _init();
	void _ready();
	void _process(float delta);
	void _notification(int notification);
	
	void sync_transform();
	void sync_math();
	
	void create_ellipse();
	void update_after_set();
	
	void set_speed(float p_speed);
	float get_speed();
	void set_radius(float p_radius);
	float get_radius();
	void set_eccentricity(float p_eccentricity);
	float get_eccentricity();
	void set_center(Vector3 p_center);
	Vector3 get_center();
	void set_normal(Vector3 p_normal);
	Vector3 get_normal();
	void set_tangent(Vector3 p_tangent);
	Vector3 get_tangent();
};

}

#endif