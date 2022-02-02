/*
    Copyright (C) 2021 Luka-sama

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

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
#define GDMATH_DEFAULT_WARP_POINT_POSITION Vector3()
#define GDMATH_DEFAULT_WARP_POINT_BASIS Basis()

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
	Vector3 warp_point_position;
	Basis warp_point_basis;
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
	
	void slower();
	void faster();
	
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
	void set_warp_point_position(Vector3 p_warp_point_position);
	Vector3 get_warp_point_position();
	void set_warp_point_basis(Basis p_warp_point_basis);
	Basis get_warp_point_basis();
};

}

#endif