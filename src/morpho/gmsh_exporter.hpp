/*
 * Copyright (C) 2015 Adrien Devresse <adrien.devresse@epfl.ch>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
 *
 */
#ifndef MESH_EXPORTER_HPP
#define MESH_EXPORTER_HPP

#include <bitset>
#include <cstddef>
#include <fstream>
#include <functional>
#include <iostream>
#include <stdexcept>
#include <string>
#include <unordered_set>

#include <hadoken/geometry/geometry.hpp>
#include <hadoken/math/math_floating_point.hpp>

#include <morpho/morpho_h5_v1.hpp>
#include <morpho/morpho_tree.hpp>

namespace morpho {

namespace geo = hadoken::geometry::cartesian;

///
/// \brief gmsh representation of a point
///
struct gmsh_point {
    inline gmsh_point() : coords(), radius(), id(0), isPhysical(false) {}

    inline gmsh_point(const geo::point3d& my_coords, double d = 1.0)
        : coords(my_coords), radius(d), id(0), isPhysical(false) {}

    inline void setPhysical(bool phys) { isPhysical = phys; }

    inline geo::point3d get_point() const { return coords; }

    /// operator == for Equal requirement
    inline bool operator==(const gmsh_point& other) const noexcept {
        return (hadoken::math::almost_equal(geo::get_x(coords),
                                            geo::get_x(other.coords)) &&
                hadoken::math::almost_equal(geo::get_y(coords),
                                            geo::get_y(other.coords)) &&
                hadoken::math::almost_equal(geo::get_z(coords),
                                            geo::get_z(other.coords)));
    }

    geo::point3d coords;
    double radius;
    std::size_t id;
    bool isPhysical;
};

/// \brief representation of a segment in 3D
struct gmsh_polyline {
    inline gmsh_polyline(const gmsh_point& p1, const gmsh_point& p2)
        : points({p1, p2}), id(0), isPhysical(false) {}

    inline gmsh_polyline(const std::vector<gmsh_point>& list_points)
        : points(list_points), id(0), isPhysical(false) {
        if (points.size() < 2) {
            throw std::out_of_range("Invalid gmsh_polyline : a polyline should "
                                    "have at least 2 points");
        }
    }

    inline void setPhysical(bool phys) { isPhysical = phys; }

    inline const gmsh_point& get_point(std::size_t id) const {
        return points[id];
    }

    /// operator == for Equal requirement
    inline bool operator==(const gmsh_polyline& other) const noexcept {
        if (other.points.size() != points.size()) {
            return false;
        }
        for (std::size_t i = 0; i < points.size(); ++i) {
            if ((points[i] == other.points[i]) == false) {
                return false;
            }
        }
        return true;
    }

    std::vector<gmsh_point> points;
    std::size_t id;
    bool isPhysical;
};

/// representation of a circle-arc in 3D
struct gmsh_circle {
    inline gmsh_circle(const gmsh_point& my_center, const gmsh_point& p1,
                       const gmsh_point& p2)
        : center(my_center), point1(p1), point2(p2), id(0), isPhysical(false) {}

    /// operator == for Equal requirement
    inline bool operator==(const gmsh_circle& other) const noexcept {
        return (center == other.center) && (point1 == other.point1) &&
               (point2 == other.point2);
    }

    inline void setPhysical(bool phys) { isPhysical = phys; }

    inline const gmsh_point& get_point(std::size_t id) const {
        switch (id) {
        case 0: {
            return point1;
        }
        case 1: {
            return point2;
        }
        default: {
            throw std::out_of_range("only 2 points accessible in gmsh_circle");
        }
        }
    }

    gmsh_point center, point1, point2;
    std::size_t id;
    bool isPhysical;
};

/// representation of a closed loop in 3D
struct gmsh_line_loop {
    inline gmsh_line_loop(const std::vector<std::int64_t>& id_list)
        : ids(id_list), id(0), isPhysical(false), isSurface(false) {}

    /// operator == for Equal requirement
    inline bool operator==(const gmsh_line_loop& other) const noexcept {
        if (ids.size() != other.ids.size()) {
            return false;
        }
        return std::equal(ids.begin(), ids.end(), other.ids.begin());
    }

    inline void setPhysical(bool phys) { isPhysical = phys; }

    inline void setSurface(bool s) { isSurface = s; }

    std::vector<std::int64_t> ids;
    std::size_t id;
    bool isPhysical, isSurface;
};

/// representation of a volume in 3D
struct gmsh_volume {
    inline gmsh_volume(const std::vector<std::size_t>& id_list)
        : ids(id_list), id(0), isPhysical(false) {}

    /// operator == for Equal requirement
    inline bool operator==(const gmsh_volume& other) const noexcept {
        if (ids.size() != other.ids.size()) {
            return false;
        }
        return std::equal(ids.begin(), ids.end(), other.ids.begin());
    }

    inline void setPhysical(bool phys) { isPhysical = phys; }

    std::vector<std::size_t> ids;
    std::size_t id;
    bool isPhysical;
};

///
/// \brief in memory abstract gmsh file representation
///
class gmsh_abstract_file : private boost::noncopyable {
  public:
    /// add a point and return its id
    std::size_t add_point(const gmsh_point& point);

    std::size_t find_point(const gmsh_point& point);

    /// add a segment and return its id
    std::size_t add_polyline(const gmsh_polyline& s);

    /// add a new gmsh circle
    std::size_t add_circle(const gmsh_circle& c);

    /// add a new line loop
    std::size_t add_line_loop(const gmsh_line_loop& l);

    /// volume in 3D
    std::size_t add_volume(const gmsh_volume& l);

    /// get all points
    std::vector<gmsh_point> get_all_points() const;

    /// get all segments
    std::vector<gmsh_polyline> get_all_segments() const;

    /// get all circles
    std::vector<gmsh_circle> get_all_circles() const;

    /// get all line loop
    std::vector<gmsh_line_loop> get_all_line_loops() const;

    std::vector<gmsh_volume> get_all_volumes() const;

    /// export all points to stream in gmsh format
    void export_points_to_stream(std::ostream& out);
    void export_points_to_stream_dmg(std::ostream& out);

    /// export all segments to stream in gmsh format
    void export_segments_to_stream(std::ostream& out);
    void export_segments_to_stream_dmg(std::ostream& out);

    /// export all segments to the stream in gmsh format
    void export_circle_to_stream(std::ostream& out);
    void export_circle_to_stream_dmg(std::ostream& out);

    /// export all segments to the stream in gmsh format
    void export_line_loop_to_stream(std::ostream& out);
    void export_line_loop_to_stream_dmg(std::ostream& out);

    /// export all segments to the stream in gmsh format
    void export_volume_to_stream(std::ostream& out);
    void export_volume_to_stream_dmg(std::ostream& out);

    /// Add a bounding box geometry based on neuron points
    void add_bounding_box();

  private:
    std::size_t create_id_line_element();

    struct hash_gmsh_point {
        std::size_t operator()(const gmsh_point& p) const noexcept {
            std::hash<double> hd;
            const double xpos = geo::get_x(p.get_point());
            // round up the value to the desired precision ( 4 digit prec )
            const double xpos_round = std::ceil(xpos * 10000);
            return hd(xpos_round);
        }
    };

    template <typename GeometryType>
    struct hash_geometry_point {
        std::size_t operator()(const GeometryType& s) const noexcept {
            std::hash<double> hd;
            return hd(geo::get_x(s.get_point(0).coords));
        }
    };

    template <typename GeometryType>
    struct hash_geometry_ids {
        std::size_t operator()(const GeometryType& s) const noexcept {
            std::hash<std::size_t> hd;
            std::size_t res = 0x1f1f1f;
            for (auto& id : s.ids) {
                res ^= hd(id);
            }
            return res;
        }
    };

    std::unordered_set<gmsh_point, hash_gmsh_point> _points;

    std::unordered_set<gmsh_polyline, hash_geometry_point<gmsh_polyline>>
        _segments;

    std::unordered_set<gmsh_circle, hash_geometry_point<gmsh_circle>> _circles;

    std::unordered_set<gmsh_line_loop, hash_geometry_ids<gmsh_line_loop>>
        _line_loop;

    std::unordered_set<gmsh_volume, hash_geometry_ids<gmsh_volume>> _volumes;
};

///
/// \brief The gmsh_exporter class
///
class gmsh_exporter {
  public:
    typedef int exporter_flags;
    static constexpr int exporter_single_soma = 0x01;
    static constexpr int exporter_write_dmg = 0x02;
    static constexpr int exporter_bounding_box = 0x04;
    static constexpr int exporter_packed = 0x08;

    gmsh_exporter(std::vector<morpho_tree>&& trees,
                  const std::string& mesh_filename,
                  exporter_flags flags = exporter_flags());

    void export_to_point_cloud();

    void export_to_wireframe();

    void export_to_3d_object();

    inline void set_identifier(const std::string& id) {
        identifier_string = id;
    }

  private:
    std::ofstream geo_stream, dmg_stream;
    exporter_flags flags;
    std::vector<morpho_tree> morphotrees;

    std::string identifier_string;

    bool is_dmg_enabled() const;
    bool is_bbox_enabled() const;
    bool is_packed() const;

    void serialize_header();

    void serialize_points_raw();

    void construct_gmsh_vfile_raw(gmsh_abstract_file& vfile);

    void construct_gmsh_vfile_lines(morpho_tree& tree, int node_id,
                                    gmsh_abstract_file& vfile);

    void construct_gmsh_3d_object(morpho_tree& tree, int node_id,
                                  gmsh_abstract_file& vfile);
};

} // morpho

#endif // MESH_EXPORTER_H
