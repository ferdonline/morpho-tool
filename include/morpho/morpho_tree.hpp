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
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */
#ifndef MORPHO_TREE_HPP
#define MORPHO_TREE_HPP

#include <bitset>
#include <memory>
#include <vector>
#include <unordered_map>

#include "morpho_types.hpp"

namespace morpho {

class section;
class morpho_tree;


enum class cell_family {
    NEURON,
    GLIA
};

enum class morpho_node_type{
    unknown = 0x00,
    neuron_node_3d_type = 0x01,
    neuron_section_type = 0x02,
    neuron_soma_type = 0x03
};

/// section type
enum class neuron_struct_type {
    soma = 0x00,
    axon = 0x01,
    dentrite_basal = 0x02,
    dentrite_apical = 0x03,
    unknown = 0x04
};

enum class glia_struct_type {
    soma = 0x00,
    glia_process = 0x01,
    glia_endfoot = 0x02
};

///
/// \brief generic element for a morphology node
///
class morpho_node {
    struct morpho_node_internal;

  public:
    morpho_node();
    morpho_node(const morpho_node& other);

    virtual ~morpho_node();

    ///
    /// pure virtual function
    /// return bounding box of the entire section
    ///
    virtual box get_bounding_box() const = 0;

    bool is_of_type(morpho_node_type mtype) const;

    // Serialization
    // virtual int serialize( const std::ostream & output ) const = 0;
    // static std::shared_ptr<morpho_node> deserialize( const std::istream &
    // input );

  protected:
    void add_type_capability(morpho_node_type mtype);

  private:
    std::unique_ptr<morpho_node_internal> _dptr;
};

///
/// \brief generic element for any neuron element
///     in cone
///
///
class neuron_node_3d : public morpho_node {
  public:
    neuron_node_3d(neuron_struct_type my_node_type);

    virtual ~neuron_node_3d();

    inline neuron_struct_type get_section_type() const { return _my_type; }

  private:
    neuron_struct_type _my_type;
};

///
/// \brief a neuron morphology section (dentrite, axon )
///    modelised by a set of truncated cones
///
class neuron_section : public neuron_node_3d {
    struct neuron_section_internal;

  public:
    neuron_section(neuron_struct_type neuron_type, std::vector<point>&& points,
                  std::vector<double>&& radius);
    neuron_section(const neuron_section& other);
    virtual ~neuron_section();

    ///
    /// \brief get_number_points
    /// \return  total number of points associated with the section
    ///
    std::size_t get_number_points() const;

    ///
    /// \brief get_points
    /// \param id
    /// \return vector of all the points of the section
    ///
    ///  each point has also its associated radius in order
    ///  accessible with get_radius
    ///
    const std::vector<point>& get_points() const;

    ///
    /// \brief get_radius
    /// \param id
    /// \return vector of all the radius of the section
    ///
    ///  each radius has also its associated point in order
    ///  accessible with get_points
    ///
    const std::vector<double>& get_radius() const;

    ///
    /// \brief provide a cone associated to a given segment
    ///  segments id are from 0 to get_number_points() -1
    ///
    /// \param if of the segment
    /// \return cone of the given section segment
    ///
    cone get_segment(std::size_t n) const;

    ///
    /// \brief bounding box
    /// \return bounding box of the entire section
    ///
    box get_bounding_box() const override;

    ///
    /// \brief bounding box of a given segment
    /// \return bounding box of for a given segment
    ///
    box get_segment_bounding_box(std::size_t n) const;

    ///
    /// \brief junction sphere between two segment
    ///
    ///
    /// The junction is modelise as a sphere of the radius at junction point
    /// between two segments.
    ///  Only the junction of the end of each segment is return
    ///  e.g junction 0 = end of the segment 0
    ///
    /// \return sphere object for radius adapted of the junction between two
    /// segments
    ///
    sphere get_junction(std::size_t n) const;

    ///
    /// \brief get_junction_sphere_bounding_box
    /// \param n
    /// \return bounding box for each junction between two segment
    ///
    box get_junction_sphere_bounding_box(std::size_t n) const;

    ///
    /// \brief get_linestring
    ///
    /// linestring object of the entire section
    ///
    /// \return linestring of the section
    ///
    linestring get_linestring() const;

    ///
    /// \brief get_circle_pipe
    /// \return
    ///
    circle_pipe get_circle_pipe() const;

  private:
    std::unique_ptr<neuron_section_internal> _dptr;
};

///
/// \brief soma section type
///
class neuron_soma : public neuron_node_3d {
    struct neuron_soma_intern;

  public:
    /// construct a soma out of a line loop
    neuron_soma(std::vector<point>&& line_loop);
    /// construct a soma out of a point and radius
    neuron_soma(const point& p, double radius);

    virtual ~neuron_soma();

    ///
    /// \brief compute simplified soma sphere
    ///
    ///  compute a simplified soma sphere
    ///  based on the soma gravity center and the average distance
    ///  between the center and the soma surface points
    ///
    /// \return
    ///
    sphere get_sphere() const;

    ///
    /// \brief bounding box
    /// \return bounding box of the entire section
    ///
    box get_bounding_box() const override;

    ///
    /// \brief get_line_loop
    /// \param id
    /// \return vector of all the point of the main lineloop defining the soma
    ///
    ///
    const std::vector<point>& get_line_loop() const;

  private:
    std::unique_ptr<neuron_soma_intern> _dptr;
};

///
/// \brief container for an entire morphology tree
///
class morpho_tree {
    struct morpho_tree_intern;

  public:
    morpho_tree();
    morpho_tree(morpho_tree&& other);
    morpho_tree(const morpho_tree&);

    morpho_tree& operator=(morpho_tree&& other);
    morpho_tree& operator=(const morpho_tree&);

    virtual ~morpho_tree();

    /// get bounding box for the entire morphology tree
    box get_bounding_box() const;

    /// get number of nodes in the tree
    /// nodes id are always from 0 to tree_size -1
    std::size_t get_tree_size() const;

    /// swap two morpho tree
    void swap(morpho_tree& other);

    /// add a new node in the tree
    /// return the id of the node
    int add_node(int parent_id, const std::shared_ptr<morpho_node>& new_node);

    ///
    /// copy node with a given id from an other tree to the current tree
    /// and assign it as child node of a given parent in the new tree
    int copy_node(const morpho_tree& other, int id, int new_parent_id);

    /// get a node, by id
    /// node ids are always from 0 to tree_size -1
    const morpho_node& get_node(int id) const;

    /// return the parent node id associated with a given node
    int get_parent(int id) const;

    ///
    /// all children of a node of a given id
    ///
    std::vector<int> get_children(int id) const;

    /// all nodes
    std::vector<morpho_node const*> get_all_nodes() const;

    void set_cell_type( cell_family cell_t );
    cell_family get_cell_type() const;



  private:
    std::unique_ptr<morpho_tree_intern> _dptr;
};

} // morpho

#endif // MORPHO_TREE_HPP

