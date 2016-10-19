#include "mesh_exporter.hpp"

#include <algorithm>
#include <vector>

#include <hadoken/format/format.hpp>

#include <morpho/morpho_h5_v1.hpp>

using namespace std;
namespace fmt = hadoken::format;


namespace morpho{

const std::string gmsh_header =
"/***************************************************************\n"
" * gmsh file generated by morpho-tool\n"
"****************************************************************/\n\n";



std::size_t gmsh_abstract_file::add_point(const gmsh_point &point){
    gmsh_point new_point(point);
    new_point.id = _points.size();
   //std::cout << "points " << geo::get_x(point.coords ) << " " << geo::get_y(point.coords ) << " " << geo::get_z(point.coords ) << std::endl;
    return _points.insert(new_point).first->id;
}

std::size_t gmsh_abstract_file::find_point(const gmsh_point &point){
    auto it = _points.find(point);
    if(it == _points.end()){
        throw std::out_of_range(fmt::scat("Impossible to find point ", geo::get_x(point.coords), " ",
                                          geo::get_y(point.coords), " ", geo::get_z(point.coords), " in list of morphology points"));
    }
    return it->id;
}

std::size_t gmsh_abstract_file::add_segment(const gmsh_segment & s){
    gmsh_segment segment(s);
    add_point(segment.point1);
    add_point(segment.point2);
    segment.id = _segments.size();

    return _segments.insert(segment).first->id;
}

std::vector<gmsh_point> gmsh_abstract_file::get_all_points() const{
    std::vector<gmsh_point> all_points;
    all_points.reserve(_points.size());

    // reorder all points by id, for geo file lisibility
    std::copy(_points.begin(), _points.end(), std::back_inserter(all_points));

    std::sort(all_points.begin(), all_points.end(), [](const gmsh_point & p1, const gmsh_point & p2){
        return (p1.id < p2.id);
    });

    return all_points;
}

std::vector<gmsh_segment> gmsh_abstract_file::get_all_segments() const{
    std::vector<gmsh_segment> all_segments;
    all_segments.reserve(_segments.size());

    std::copy(_segments.begin(), _segments.end(), std::back_inserter(all_segments));

    std::sort(all_segments.begin(), all_segments.end(), [](const gmsh_segment & p1, const gmsh_segment & p2){
        return (p1.id < p2.id);
    });

    return all_segments;
}


void gmsh_abstract_file::export_points_to_stream(ostream &out){
    out << "\n";
    out << "// export morphology points \n";

    auto all_points = get_all_points();

    for(auto p = all_points.begin(); p != all_points.end(); ++p){
        fmt::scat(out,
                  "Point(", p->id,") = {", geo::get_x(p->coords),", ", geo::get_y(p->coords), ", ", geo::get_z(p->coords), ", ", p->diameter,"};\n");
        if(p->isPhysical){
            fmt::scat(out,
                      "Physical Point(", p->id,") = {", p->id,"};\n");
        }
    }

    out << "\n\n";
}


void gmsh_abstract_file::export_segments_to_stream(ostream &out){
    out << "\n";
    out << "// export morphology segments \n";

    auto all_segments = get_all_segments();

    for(auto p = all_segments.begin(); p != all_segments.end(); ++p){
        fmt::scat(out,
                  "Line(", p->id,") = {" , find_point(p->point1),", ", find_point(p->point2),"};\n");
        if(p->isPhysical){
            fmt::scat(out,
                      "Physical Line(", p->id,") = {", p->id,"};\n");
        }
    }

    out << "\n\n";
}


gmsh_exporter::gmsh_exporter(const std::string & morphology_filename, const std::string & mesh_filename, exporter_flags my_flags) :
    geo_stream(mesh_filename),
    reader(morphology_filename),
    flags(my_flags)
{


}


void gmsh_exporter::export_to_point_cloud(){
    serialize_header();
    serialize_points_raw();
}


void gmsh_exporter::export_to_wireframe(){
    serialize_header();

    morpho_tree tree = reader.create_morpho_tree();

    gmsh_abstract_file vfile;
    construct_gmsh_vfile_lines(tree, tree.get_branch(0), vfile);

    vfile.export_points_to_stream(geo_stream);
    vfile.export_segments_to_stream(geo_stream);
}



void gmsh_exporter::serialize_header(){
    geo_stream << gmsh_header << "\n";


    fmt::scat(geo_stream,
              gmsh_header,
              "// converted to GEO format from ", reader.get_filename(), "\n");

}


void gmsh_exporter::construct_gmsh_vfile_raw(gmsh_abstract_file & vfile){

    auto points = reader.get_points_raw();

    assert(points.size2() > 3);

    for(std::size_t row =0; row < points.size1(); ++row){
        gmsh_point point(geo::point3d( points(row, 0), points(row, 1), points(row, 2)), points(row, 3));
        vfile.add_point(point);
    }

}

void gmsh_exporter::construct_gmsh_vfile_lines(morpho_tree & tree, branch & current_branch, gmsh_abstract_file & vfile){

    const auto linestring = current_branch.get_linestring();
    if(linestring.size() > 1 && !(current_branch.get_type() == branch_type::soma && (flags & exporter_single_soma))){
        for(std::size_t i =0; i < (linestring.size()-1); ++i){
            gmsh_point p1(linestring[i], 1.0);
            p1.setPhysical(true);
            gmsh_point p2(linestring[i+1], 1.0);
            p2.setPhysical(true);

            gmsh_segment segment(p1, p2);
            segment.setPhysical(true);
            vfile.add_segment(segment);
        }
    }

    const auto & childrens = current_branch.get_childrens();
    for( auto & c : childrens){
        branch & child_branch = tree.get_branch(c);
        construct_gmsh_vfile_lines(tree, child_branch, vfile);
    }
}



void gmsh_exporter::serialize_points_raw(){
    gmsh_abstract_file vfile;
    construct_gmsh_vfile_raw(vfile);
    vfile.export_points_to_stream(geo_stream);
}



} // morpho
