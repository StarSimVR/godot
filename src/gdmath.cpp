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
 * @brief       Define methods of GDMath
 * @copyright   (C) 2022 Luka-sama.
 *              This file is licensed GPL 2 as of June 1991.
 * @date        2022
 * @file        gdmath.h
 * @note        See `LICENSE' for full license.
 *              See `README.md' for project details.
 *
 * This source file defines methods of GDMath.
 */

/******************************************************************************/

/*
 * Includes.
 */

#include "GDMath.h"

using namespace godot;

/**
 * @brief   GDMath constructor.
 *
 * Construct a new instance of GDMath. Does nothing.
 */
GDMath::GDMath() {
}

/**
 * @brief   GDMath destructor.
 *
 * This destructor makes clean up before GDMath deleting.
 */
GDMath::~GDMath() {
	delete ellipse;
}

/**
 * This method registers properties and methods for GDNative.
 */
void GDMath::_register_methods() {
	register_method("_ready", &GDMath::_ready);
	register_method("_process", &GDMath::_process);
	register_method("_notification", &GDMath::_notification);
	
	register_property<GDMath, float>("speed", &GDMath::set_speed, &GDMath::get_speed, GDMATH_DEFAULT_SPEED);
	register_property<GDMath, float>("radius", &GDMath::set_radius, &GDMath::get_radius, GDMATH_DEFAULT_RADIUS);
	register_property<GDMath, float>("eccentricity", &GDMath::set_eccentricity, &GDMath::get_eccentricity, GDMATH_DEFAULT_ECCENTRICITY);
	register_property<GDMath, Vector3>("centre", &GDMath::set_center, &GDMath::get_center, GDMATH_DEFAULT_CENTER);
	register_property<GDMath, Vector3>("normal", &GDMath::set_normal, &GDMath::get_normal, GDMATH_DEFAULT_NORMAL);
	register_property<GDMath, Vector3>("tangent", &GDMath::set_tangent, &GDMath::get_tangent, GDMATH_DEFAULT_TANGENT);
	register_property<GDMath, Vector3>("warp_point_position", &GDMath::set_warp_point_position, &GDMath::get_warp_point_position, GDMATH_DEFAULT_WARP_POINT_POSITION);
	register_property<GDMath, Basis>("warp_point_basis", &GDMath::set_warp_point_basis, &GDMath::get_warp_point_basis, GDMATH_DEFAULT_WARP_POINT_BASIS);
	register_method("slower", &GDMath::slower);
	register_method("faster", &GDMath::faster);
}

/**
 * This method initializes parameters with default values.
 */
void GDMath::_init() {
	ellipse = NULL;
	time_passed = 0.0;
	is_ready = false;
	
	speed = GDMATH_DEFAULT_SPEED;
	radius = GDMATH_DEFAULT_RADIUS;
	eccentricity = GDMATH_DEFAULT_ECCENTRICITY;
	center = GDMATH_DEFAULT_CENTER;
	normal = GDMATH_DEFAULT_NORMAL;
	tangent = GDMATH_DEFAULT_TANGENT;
	warp_point_position = GDMATH_DEFAULT_WARP_POINT_POSITION;
	warp_point_basis = GDMATH_DEFAULT_WARP_POINT_BASIS;
}

/**
 * This method creates ellipse if we are in editor and synchronizes parameters if we are not.
 */
void GDMath::_ready() {
	is_ready = true;
	if (!Engine::get_singleton()->is_editor_hint()) {
		create_ellipse();
	} else {
		set_notify_transform(true);
	}
}

/**
 * This method does movement using `Ellipse` class.
 */
void GDMath::_process(float delta) {
	if (!Engine::get_singleton()->is_editor_hint()) {
		time_passed += speed * delta;
		vector<float> v = ellipse->eval(time_passed);
		set_translation( Vector3(v[0], v[1], v[2]) );
	}
}

/**
 * This method calls math synchronization if needed.
 */
void GDMath::_notification(int notification) {
	if (notification == NOTIFICATION_TRANSFORM_CHANGED && Engine::get_singleton()->is_editor_hint() && is_ready) {
		sync_math();
		property_list_changed_notify();
	}
}

/**
 * This method synchronizes transform.
 */
void GDMath::sync_transform() {
	set_translation(center);
}

/**
 * This method synchronizes math.
 */
void GDMath::sync_math() {
	center = get_translation();
}

/**
 * This method creates new `Ellipse` instance.
 */
void GDMath::create_ellipse() {
	ellipse = new Ellipse(radius, eccentricity, center.x, center.y, center.z, tangent.x, tangent.y, tangent.z, normal.x, normal.y, normal.z);
}

/**
 * This method calls transform synchronization if needed and updates `Ellipse` instance.
 */
void GDMath::update_after_set() {
	if (ellipse) {
		delete ellipse;
		create_ellipse();
	}
	if (Engine::get_singleton()->is_editor_hint() && is_ready) {
		sync_transform();
		property_list_changed_notify();
	}
}

/**
 * This method makes the object twice as slow.
 */
void GDMath::slower() {
	speed *= 0.5f;
}

/**
 * This method makes the object twice as fast.
 */
void GDMath::faster() {
	speed *= 2.f;
}

/**
 * @param   p_speed   Speed to set.
 * This method sets the speed of the object.
 */
void GDMath::set_speed(float p_speed) {
	speed = p_speed;
	update_after_set();
}
/**
 * This method gets the speed of the object.
 */
float GDMath::get_speed() {
	return speed;
}

/**
 * @param   p_radius   Radius to set.
 * This method sets the radius of the object.
 */
void GDMath::set_radius(float p_radius) {
	radius = p_radius;
	update_after_set();
}
/**
 * This method gets the radius of the object.
 */
float GDMath::get_radius() {
	return radius;
}

/**
 * @param   p_eccentricity   Eccentricity to set.
 * This method sets the eccentricity of the object.
 */
void GDMath::set_eccentricity(float p_eccentricity) {
	eccentricity = p_eccentricity;
	update_after_set();
}
/**
 * This method gets the eccentricity of the object.
 */
float GDMath::get_eccentricity() {
	return eccentricity;
}

/**
 * @param   p_center   Center to set.
 * This method sets the center of the object.
 */
void GDMath::set_center(Vector3 p_center) {
	center = p_center;
	update_after_set();
}
/**
 * This method gets the center of the object.
 */
Vector3 GDMath::get_center() {
	return center;
}

/**
 * @param   p_normal   Normal to set.
 * This method sets the normal of the object.
 */
void GDMath::set_normal(Vector3 p_normal) {
	normal = p_normal;
	update_after_set();
}
/**
 * This method gets the normal of the object.
 */
Vector3 GDMath::get_normal() {
	return normal;
}

/**
 * @param   p_tangent   Tangent to set.
 * This method sets the tangent of the object.
 */
void GDMath::set_tangent(Vector3 p_tangent) {
	tangent = p_tangent;
	update_after_set();
}
/**
 * This method gets the tangent of the object.
 */
Vector3 GDMath::get_tangent() {
	return tangent;
}

/**
 * @param   p_warp_point_position   Warp point position to set.
 * This method sets the warp point position of the object.
 */
void GDMath::set_warp_point_position(Vector3 p_warp_point_position) {
	warp_point_position = p_warp_point_position;
	update_after_set();
}
/**
 * This method gets the warp point position of the object.
 */
Vector3 GDMath::get_warp_point_position() {
	return warp_point_position;
}

/**
 * @param   p_warp_point_basis   Warp point basis to set.
 * This method sets the warp point basis of the object.
 */
void GDMath::set_warp_point_basis(Basis p_warp_point_basis) {
	warp_point_basis = p_warp_point_basis;
	update_after_set();
}
/**
 * This method gets the warp point basis of the object.
 */
Basis GDMath::get_warp_point_basis() {
	return warp_point_basis;
}

/******************************************************************************/