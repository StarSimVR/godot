#ifndef GDMATH_H
#define GDMATH_H

#include <Godot.hpp>
#include <Spatial.hpp>
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
	static const float DEFAULT_SPEED;
	static const float DEFAULT_RADIUS;
	static const float DEFAULT_ECCENTRICITY;
	static const Vector3 DEFAULT_CENTER;
	static const Vector3 DEFAULT_NORMAL;
	static const Vector3 DEFAULT_TANGENT;
	
	Ellipse* ellipse;
	float time_passed;
	
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
	
	void create_ellipse();
	void recreate_ellipse();
	
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