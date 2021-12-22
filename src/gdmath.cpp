#include "GDMath.h"
#include <ellipse.hpp>

using namespace godot;

GDMath::GDMath() {
}

GDMath::~GDMath() {
	delete ellipse;
}

void GDMath::_register_methods() {
	register_method("_ready", &GDMath::_ready);
	register_method("_process", &GDMath::_process);
	
	register_property<GDMath, float>("speed", &GDMath::set_speed, &GDMath::get_speed, GDMATH_DEFAULT_SPEED);
	register_property<GDMath, float>("radius", &GDMath::set_radius, &GDMath::get_radius, GDMATH_DEFAULT_RADIUS);
	register_property<GDMath, float>("eccentricity", &GDMath::set_eccentricity, &GDMath::get_eccentricity, GDMATH_DEFAULT_ECCENTRICITY);
	register_property<GDMath, Vector3>("centre", &GDMath::set_center, &GDMath::get_center, GDMATH_DEFAULT_CENTER);
	register_property<GDMath, Vector3>("normal", &GDMath::set_normal, &GDMath::get_normal, GDMATH_DEFAULT_NORMAL);
	register_property<GDMath, Vector3>("tangent", &GDMath::set_tangent, &GDMath::get_tangent, GDMATH_DEFAULT_TANGENT);
}

void GDMath::_init() {
	ellipse = NULL;
	time_passed = 0.0;
	
	speed = GDMATH_DEFAULT_SPEED;
	radius = GDMATH_DEFAULT_RADIUS;
	eccentricity = GDMATH_DEFAULT_ECCENTRICITY;
	center = GDMATH_DEFAULT_CENTER;
	normal = GDMATH_DEFAULT_NORMAL;
	tangent = GDMATH_DEFAULT_TANGENT;
}

void GDMath::_ready() {
	create_ellipse();
}

void GDMath::_process(float delta) {
	time_passed += speed * delta;
	vector<float> v = ellipse->eval(time_passed);
	set_translation( Vector3(v[0], v[1], v[2]) );
}

void GDMath::create_ellipse() {
	ellipse = new Ellipse(radius, eccentricity, center.x, center.y, center.z, tangent.x, tangent.y, tangent.z, normal.x, normal.y, normal.z);
}
void GDMath::recreate_ellipse() {
	if (ellipse) {
		delete ellipse;
		ellipse = new Ellipse(radius, eccentricity, center.x, center.y, center.z, tangent.x, tangent.y, tangent.z, normal.x, normal.y, normal.z);
	}
}

void GDMath::set_speed(float p_speed) {
	speed = p_speed;
	recreate_ellipse();
}
float GDMath::get_speed() {
	return speed;
}

void GDMath::set_radius(float p_radius) {
	radius = p_radius;
	recreate_ellipse();
}
float GDMath::get_radius() {
	return radius;
}

void GDMath::set_eccentricity(float p_eccentricity) {
	eccentricity = p_eccentricity;
	recreate_ellipse();
}
float GDMath::get_eccentricity() {
	return eccentricity;
}

void GDMath::set_center(Vector3 p_center) {
	center = p_center;
	recreate_ellipse();
}
Vector3 GDMath::get_center() {
	return center;
}

void GDMath::set_normal(Vector3 p_normal) {
	normal = p_normal;
	recreate_ellipse();
}
Vector3 GDMath::get_normal() {
	return normal;
}

void GDMath::set_tangent(Vector3 p_tangent) {
	tangent = p_tangent;
	recreate_ellipse();
}
Vector3 GDMath::get_tangent() {
	return tangent;
}