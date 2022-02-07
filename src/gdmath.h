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

/**
 * @author      Luka-sama
 * @brief       Introducing the `GDMath' class.
 * @copyright   (C) 2022 Luka-sama.
 *              This file is licensed GPL 2 as of June 1991.
 * @date        2022
 * @file        gdmath.h
 * @note        See `LICENSE' for full license.
 *              See `README.md' for project details.
 *
 * This is the main header of the repository introducing the `GDMath` class.
 *
 * The introduced class is intended to simulate planetary motion using
 * `Ellipse` class.
 */

/******************************************************************************/

/*
 * Security settings.
 */


#ifndef GDMATH_H
#define GDMATH_H

/*
 * Includes.
 */

#include <Godot.hpp>
#include <Spatial.hpp>
#include <Engine.hpp>
#include <ellipse.hpp>


/*
 * Constants with default values for parameters.
 */

/**
 * Default speed.
*/
#define GDMATH_DEFAULT_SPEED 1.0
/**
 * Default radius.
*/
#define GDMATH_DEFAULT_RADIUS 1.0
/**
 * Default eccentricity.
*/
#define GDMATH_DEFAULT_ECCENTRICITY 1.0
/**
 * Default center.
*/
#define GDMATH_DEFAULT_CENTER Vector3(1.0, 1.0, 1.0)
/**
 * Default normal.
*/
#define GDMATH_DEFAULT_NORMAL Vector3(1.0, 1.0, 1.0)
/**
 * Default tangent.
*/
#define GDMATH_DEFAULT_TANGENT Vector3(1.0, 1.0, 1.0)
/**
 * Default warp point position.
*/
#define GDMATH_DEFAULT_WARP_POINT_POSITION Vector3()
/**
 * Default warp point basis.
*/
#define GDMATH_DEFAULT_WARP_POINT_BASIS Basis()

namespace godot {

/**
 * @brief   This class simulates planetary motion.
 *
 * This class is intended to simulate planetary motion using
 * `Ellipse` class. It passes the required parameters to
 * `Ellipse` instance and handles speed of the objects.
 *
 * It can also synchronize some parameters between instances
 * of this class and `Ellipse` class.
 */

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

/*
 * End of header.
 */

// Leaving the header.
#endif // ! GDMATH_H

/******************************************************************************/