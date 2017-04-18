# -*- coding: utf-8 -*-
# =====================================================================================================================
# These bindings were automatically generated by cyWrap. Please do dot modify.
# Additional functionality shall be implemented in sub-classes.
#
__copyright__ = "Copyright 2016 EPFL BBP-project"
# =====================================================================================================================
include "_base.pxi"

cimport morpho
from .statics cimport morpho_morpho_node_type
from .statics cimport morpho_neuron_struct_type
cimport morpho_h5_v1
from .statics cimport morpho_h5_v1_morpho_reader
cimport stats

include "datastructs.pxi"


# ======================================================================================================================
# Python bindings to namespace morpho
# ======================================================================================================================

# ----------------------------------------------------------------------------------------------------------------------
cdef class MORPHO_NODE_TYPE(_Enum):
    unknown = morpho_morpho_node_type.unknown
    neuron_node_3d_type = morpho_morpho_node_type.neuron_node_3d_type
    neuron_branch_type = morpho_morpho_node_type.neuron_branch_type
    neuron_soma_type = morpho_morpho_node_type.neuron_soma_type


# ----------------------------------------------------------------------------------------------------------------------
cdef class NEURON_STRUCT_TYPE(_Enum):
    soma = morpho_neuron_struct_type.soma
    axon = morpho_neuron_struct_type.axon
    dentrite_basal = morpho_neuron_struct_type.dentrite_basal
    dentrite_apical = morpho_neuron_struct_type.dentrite_apical
    unknown = morpho_neuron_struct_type.unknown


# ----------------------------------------------------------------------------------------------------------------------
cdef class MorphoNode(_py__base):
    "Python wrapper class for morpho_node (ns=morpho)"
# ----------------------------------------------------------------------------------------------------------------------
    cdef std.shared_ptr[morpho.morpho_node] _autodealoc
    cdef morpho.morpho_node *ptr0(self):
        return <morpho.morpho_node*> self._ptr

    def get_bounding_box(self, ):
        return _Box.from_value(self.ptr0().get_bounding_box())

    def is_of_type(self, int mtype):
        return self.ptr0().is_of_type(<morpho.morpho_node_type> mtype)

    @staticmethod
    cdef MorphoNode from_ptr(const morpho.morpho_node *ptr, bool owner=False):
        # Downcast nodes to specific types
        # this is the only function that introduces some program logic.
        # The same could be done with dynamic_cast, but would be less obvious and more verbose
        if ptr.is_of_type(morpho_morpho_node_type.neuron_branch_type):
            return NeuronBranch.from_ptr(<const morpho.neuron_branch *>ptr, owner)
        if ptr.is_of_type(morpho_morpho_node_type.neuron_soma_type):
            return NeuronSoma.from_ptr(<const morpho.neuron_soma*>ptr, owner)
        if ptr.is_of_type(morpho_morpho_node_type.neuron_node_3d_type):
            return NeuronNode3D.from_ptr(<const morpho.neuron_node_3d*>ptr, owner)

        # default return just "MorphoNode"
        cdef MorphoNode obj = MorphoNode.__new__(MorphoNode)
        obj._ptr = <morpho.morpho_node*>ptr
        if owner: obj._autodealoc.reset(obj.ptr0())
        return obj
    
    @staticmethod
    cdef MorphoNode from_ref(const morpho.morpho_node &ref):
        return MorphoNode.from_ptr(<morpho.morpho_node*>&ref)

    @staticmethod
    cdef list vectorPtr2list(std.vector[const morpho.morpho_node*] vec):
        return [MorphoNode.from_ptr(elem) for elem in vec]



# ----------------------------------------------------------------------------------------------------------------------
cdef class NeuronNode3D(MorphoNode):
    "Python wrapper class for neuron_node_3d (ns=morpho)"
# ----------------------------------------------------------------------------------------------------------------------
    cdef morpho.neuron_node_3d *ptr1(self):
        return <morpho.neuron_node_3d*> self._ptr

    def get_branch_type(self, ):
        return _EnumItem(NEURON_STRUCT_TYPE, <int>self.ptr1().get_branch_type())

    def is_of_type(self, int mtype):
        return self.ptr1().is_of_type(<morpho.morpho_node_type> mtype)

    @staticmethod
    cdef NeuronNode3D from_ptr(const morpho.neuron_node_3d *ptr, bool owner=False):
        cdef NeuronNode3D obj = NeuronNode3D.__new__(NeuronNode3D)
        obj._ptr = <morpho.neuron_node_3d *>ptr
        if owner: obj._autodealoc.reset(obj.ptr1())
        return obj
    
    @staticmethod
    cdef NeuronNode3D from_ref(const morpho.neuron_node_3d &ref):
        return NeuronNode3D.from_ptr(<morpho.neuron_node_3d*>&ref)

    @staticmethod
    cdef list vectorPtr2list(std.vector[morpho.neuron_node_3d*] vec):
        return [NeuronNode3D.from_ptr(elem) for elem in vec]



# ----------------------------------------------------------------------------------------------------------------------
cdef class NeuronBranch(NeuronNode3D):
    "Python wrapper class for neuron_branch (ns=morpho)"
# ----------------------------------------------------------------------------------------------------------------------
    cdef morpho.neuron_branch *ptr2(self):
        return <morpho.neuron_branch*> self._ptr

    def __init__(self, int neuron_type, _PointVector points, std.vector[double] radius):
        self._ptr = new morpho.neuron_branch(<morpho.neuron_struct_type> neuron_type, morpho.move_PointVector(deref(points.ptr())), morpho.move_DoubleVec(radius))
        self._autodealoc.reset(self.ptr2())

    def is_of_type(self, int mtype):
        return self.ptr2().is_of_type(<morpho.morpho_node_type> mtype)

    def get_number_points(self, ):
        return self.ptr2().get_number_points()

    def get_points(self, ):
        return _PointVector.from_ref(self.ptr2().get_points())

    def get_radius(self, ):
        return self.ptr2().get_radius()

    def get_segment(self, size_t n):
        return _Cone.from_value(self.ptr2().get_segment(n))

    def get_bounding_box(self, ):
        return _Box.from_value(self.ptr2().get_bounding_box())

    def get_segment_bounding_box(self, size_t n):
        return _Box.from_value(self.ptr2().get_segment_bounding_box(n))

    def get_junction(self, size_t n):
        return _Sphere.from_value(self.ptr2().get_junction(n))

    def get_junction_sphere_bounding_box(self, size_t n):
        return _Box.from_value(self.ptr2().get_junction_sphere_bounding_box(n))

    def get_linestring(self, ):
        return _Linestring.from_value(self.ptr2().get_linestring())

    def get_circle_pipe(self, ):
        return _CirclePipe.from_value(self.ptr2().get_circle_pipe())

    @staticmethod
    cdef NeuronBranch from_ptr(const morpho.neuron_branch *ptr, bool owner=False):
        cdef NeuronBranch obj = NeuronBranch.__new__(NeuronBranch)
        obj._ptr = <morpho.neuron_branch *>ptr
        if owner: obj._autodealoc.reset(obj.ptr2())
        return obj
    
    @staticmethod
    cdef NeuronBranch from_ref(const morpho.neuron_branch &ref):
        return NeuronBranch.from_ptr(<morpho.neuron_branch*>&ref)

    @staticmethod
    cdef NeuronBranch from_value(const morpho.neuron_branch &ref):
        cdef morpho.neuron_branch *ptr = new morpho.neuron_branch(ref)
        return NeuronBranch.from_ptr(ptr, True)

    @staticmethod
    cdef list vectorPtr2list(std.vector[morpho.neuron_branch*] vec):
        return [NeuronBranch.from_ptr(elem) for elem in vec]

    # @staticmethod
    # cdef list vector2list(std.vector[morpho.neuron_branch] vec):
    #     return [NeuronBranch.from_value(elem) for elem in vec]



# ----------------------------------------------------------------------------------------------------------------------
cdef class NeuronSoma(NeuronNode3D):
    "Python wrapper class for neuron_soma (ns=morpho)"
# ----------------------------------------------------------------------------------------------------------------------
    cdef morpho.neuron_soma *ptr2(self):
        return <morpho.neuron_soma*> self._ptr

    def is_of_type(self, int mtype):
        return self.ptr2().is_of_type(<morpho.morpho_node_type> mtype)

    def get_sphere(self, ):
        return _Sphere.from_value(self.ptr2().get_sphere())

    def get_bounding_box(self, ):
        return _Box.from_value(self.ptr2().get_bounding_box())

    def get_line_loop(self, ):
        return _PointVector.from_ref(self.ptr2().get_line_loop())

    @staticmethod
    cdef NeuronSoma from_ptr(const morpho.neuron_soma *ptr, bool owner=False):
        if not ptr: return None
        cdef NeuronSoma obj = NeuronSoma.__new__(NeuronSoma)
        obj._ptr = <morpho.neuron_soma *>ptr
        if owner: obj._autodealoc.reset(obj.ptr2())
        return obj
    
    @staticmethod
    cdef NeuronSoma from_ref(const morpho.neuron_soma &ref):
        return NeuronSoma.from_ptr(<morpho.neuron_soma*>&ref)

    @staticmethod
    cdef list vectorPtr2list(std.vector[morpho.neuron_soma*] vec):
        return [NeuronSoma.from_ptr(elem) for elem in vec]



# ----------------------------------------------------------------------------------------------------------------------
cdef class MorphoTree(_py__base):
    "Python wrapper class for morpho_tree (ns=morpho)"
# ----------------------------------------------------------------------------------------------------------------------
    cdef std.shared_ptr[morpho.morpho_tree] _sharedPtr
    cdef morpho.morpho_tree *ptr(self):
        return <morpho.morpho_tree*> self._ptr

    def __init__(self, MorphoTree other=None):
        if other:
            self._ptr = new morpho.morpho_tree(deref(other.ptr()))
        else: new morpho.morpho_tree()
        self._sharedPtr.reset(self.ptr())

    def get_bounding_box(self, ):
        return _Box.from_value(self.ptr().get_bounding_box())

    def get_tree_size(self, ):
        return self.ptr().get_tree_size()

    def swap(self, MorphoTree other):
        return self.ptr().swap(deref(other.ptr()))

    def add_node(self, int parent_id, MorphoNode new_node):
        return self.ptr().add_node(parent_id, new_node._autodealoc)

    def copy_node(self, MorphoTree other, int id_, int new_parent_id):
        return self.ptr().copy_node(deref(other.ptr()), id_, new_parent_id)

    def get_node(self, int id_):
        return MorphoNode.from_ref(self.ptr().get_node(id_))

    def get_parent(self, int id_):
        return self.ptr().get_parent(id_)

    def get_children(self, int id_):
        return self.ptr().get_children(id_)

    def get_all_nodes(self, ):
        return MorphoNode.vectorPtr2list(self.ptr().get_all_nodes())

    def find_nodes(self, int mtype):
        return MorphoNode.vectorPtr2list(self.ptr().find_nodes(<morpho.neuron_struct_type>mtype))

    def get_soma(self):
        return NeuronSoma.from_ptr(self.ptr().get_soma())

    @staticmethod
    cdef MorphoTree from_ptr(const morpho.morpho_tree *ptr, bool owner=False):
        cdef MorphoTree obj = MorphoTree.__new__(MorphoTree)
        obj._ptr = <morpho.morpho_tree *>ptr
        if owner: obj._sharedPtr.reset(obj.ptr())
        return obj
    
    @staticmethod
    cdef MorphoTree from_ref(const morpho.morpho_tree &ref):
        return MorphoTree.from_ptr(<morpho.morpho_tree*>&ref)

    @staticmethod
    cdef MorphoTree from_value(const morpho.morpho_tree &ref):
        cdef morpho.morpho_tree *ptr = new morpho.morpho_tree(ref)
        return MorphoTree.from_ptr(ptr, True)

    @staticmethod
    cdef MorphoTree from_move(morpho.morpho_tree &&ref):
        # this is currently not working...
        cdef MorphoTree obj = MorphoTree()
        obj.ptr().swap(ref)
        return obj

    @staticmethod
    cdef list vectorPtr2list(std.vector[morpho.morpho_tree*] vec):
        return [MorphoTree.from_ptr(elem) for elem in vec]

    # @staticmethod
    # cdef list vector2list(std.vector[morpho.morpho_tree] vec):
    #     return [MorphoTree.from_value(elem) for elem in vec]



# ======================================================================================================================
# Python bindings to namespace morpho::h5_v1
# ======================================================================================================================

# ----------------------------------------------------------------------------------------------------------------------
cdef class MorphoReader(_py__base):
    "Python wrapper class for morpho_reader (ns=morpho::h5_v1)"
# ----------------------------------------------------------------------------------------------------------------------
    cdef unique_ptr[morpho_h5_v1.morpho_reader] _autodealoc
    cdef morpho_h5_v1.morpho_reader *ptr(self):
        return <morpho_h5_v1.morpho_reader*> self._ptr

    def __init__(self, std.string filename):
        self._ptr = new morpho_h5_v1.morpho_reader(filename)
        self._autodealoc.reset(self.ptr())

    def get_points_raw(self, ):
        return _Mat_Points.from_value(self.ptr().get_points_raw())

    def get_soma_points_raw(self, ):
        return _Mat_Points.from_value(self.ptr().get_soma_points_raw())

    def get_struct_raw(self, ):
        return _Mat_Index.from_value(self.ptr().get_struct_raw())

    def get_branch_range_raw(self, int id_):
        return self.ptr().get_branch_range_raw(id_)

    def get_filename(self, ):
        return self.ptr().get_filename()

    def create_morpho_tree(self, ):
        return MorphoTree.from_value(self.ptr().create_morpho_tree())

    @staticmethod
    cdef MorphoReader from_ptr(morpho_h5_v1.morpho_reader *ptr, bool owner=False):
        cdef MorphoReader obj = MorphoReader.__new__(MorphoReader)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(obj.ptr())
        return obj
    
    @staticmethod
    cdef MorphoReader from_ref(const morpho_h5_v1.morpho_reader &ref):
        return MorphoReader.from_ptr(<morpho_h5_v1.morpho_reader*>&ref)

    @staticmethod
    cdef MorphoReader from_value(const morpho_h5_v1.morpho_reader &ref):
        cdef morpho_h5_v1.morpho_reader *ptr = new morpho_h5_v1.morpho_reader(ref)
        return MorphoReader.from_ptr(ptr, True)

    @staticmethod
    cdef list vectorPtr2list(std.vector[morpho_h5_v1.morpho_reader*] vec):
        return [MorphoReader.from_ptr(elem) for elem in vec]

    # @staticmethod
    # cdef list vector2list(std.vector[morpho_h5_v1.morpho_reader] vec):
    #     return [MorphoReader.from_value(elem) for elem in vec]



# ----------------------------------------------------------------------------------------------------------------------
cdef class MorphoWriter(_py__base):
    "Python wrapper class for morpho_writer (ns=morpho::h5_v1)"
# ----------------------------------------------------------------------------------------------------------------------
    cdef unique_ptr[morpho_h5_v1.morpho_writer] _autodealoc
    cdef morpho_h5_v1.morpho_writer *ptr(self):
        return <morpho_h5_v1.morpho_writer*> self._ptr


    def __init__(self, std.string filename):
        self._ptr = new morpho_h5_v1.morpho_writer(filename)
        self._autodealoc.reset(self.ptr())

    def write(self, MorphoTree tree):
        return self.ptr().write(deref(tree.ptr()))

    @staticmethod
    cdef MorphoWriter from_ptr(morpho_h5_v1.morpho_writer *ptr, bool owner=False):
        cdef MorphoWriter obj = MorphoWriter.__new__(MorphoWriter)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(obj.ptr())
        return obj
    
    @staticmethod
    cdef MorphoWriter from_ref(const morpho_h5_v1.morpho_writer &ref):
        return MorphoWriter.from_ptr(<morpho_h5_v1.morpho_writer*>&ref)

    @staticmethod
    cdef MorphoWriter from_value(const morpho_h5_v1.morpho_writer &ref):
        cdef morpho_h5_v1.morpho_writer *ptr = new morpho_h5_v1.morpho_writer(ref)
        return MorphoWriter.from_ptr(ptr, True)

    @staticmethod
    cdef list vectorPtr2list(std.vector[morpho_h5_v1.morpho_writer*] vec):
        return [MorphoWriter.from_ptr(elem) for elem in vec]

    # @staticmethod
    # cdef list vector2list(std.vector[morpho_h5_v1.morpho_writer] vec):
    #     return [MorphoWriter.from_value(elem) for elem in vec]



# ----------------------------------------------------------------------------------------------------------------------
cdef class _py_delete_duplicate_point_operation(_py__base):
    "Python wrapper class for delete_duplicate_point_operation (ns=morpho)"
# ----------------------------------------------------------------------------------------------------------------------
    cdef unique_ptr[morpho.delete_duplicate_point_operation] _autodealoc
    cdef morpho.delete_duplicate_point_operation *ptr(self):
        return <morpho.delete_duplicate_point_operation*> self._ptr

    def __init__(self, ):
        self._ptr = new morpho.delete_duplicate_point_operation()
        self._autodealoc.reset(self.ptr())

    def apply(self, MorphoTree tree):
        return MorphoTree.from_value(self.ptr().apply(deref(tree.ptr())))

    def name(self, ):
        return self.ptr().name()

    @staticmethod
    cdef _py_delete_duplicate_point_operation from_ptr(morpho.delete_duplicate_point_operation *ptr, bool owner=False):
        cdef _py_delete_duplicate_point_operation obj = _py_delete_duplicate_point_operation.__new__(_py_delete_duplicate_point_operation)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(obj.ptr())
        return obj

    @staticmethod
    cdef _py_delete_duplicate_point_operation from_ref(const morpho.delete_duplicate_point_operation &ref):
        return _py_delete_duplicate_point_operation.from_ptr(<morpho.delete_duplicate_point_operation*>&ref)

    @staticmethod
    cdef _py_delete_duplicate_point_operation from_value(const morpho.delete_duplicate_point_operation &ref):
        cdef morpho.delete_duplicate_point_operation *ptr = new morpho.delete_duplicate_point_operation(ref)
        return _py_delete_duplicate_point_operation.from_ptr(ptr, True)

    @staticmethod
    cdef list vectorPtr2list(std.vector[morpho.delete_duplicate_point_operation*] vec):
        return [_py_delete_duplicate_point_operation.from_ptr(elem) for elem in vec]

    @staticmethod
    cdef list vector2list(std.vector[morpho.delete_duplicate_point_operation] vec):
        return [_py_delete_duplicate_point_operation.from_value(elem) for elem in vec]



# ----------------------------------------------------------------------------------------------------------------------
cdef class _py_duplicate_first_point_operation(_py__base):
    "Python wrapper class for duplicate_first_point_operation (ns=morpho)"
# ----------------------------------------------------------------------------------------------------------------------
    cdef unique_ptr[morpho.duplicate_first_point_operation] _autodealoc
    cdef morpho.duplicate_first_point_operation *ptr(self):
        return <morpho.duplicate_first_point_operation*> self._ptr


    def __init__(self, ):
        self._ptr = new morpho.duplicate_first_point_operation()
        self._autodealoc.reset(self.ptr())

    def apply(self, MorphoTree tree):
        return MorphoTree.from_value(self.ptr().apply(deref(tree.ptr())))

    def name(self, ):
        return self.ptr().name()

    @staticmethod
    cdef _py_duplicate_first_point_operation from_ptr(morpho.duplicate_first_point_operation *ptr, bool owner=False):
        cdef _py_duplicate_first_point_operation obj = _py_duplicate_first_point_operation.__new__(_py_duplicate_first_point_operation)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(obj.ptr())
        return obj

    @staticmethod
    cdef _py_duplicate_first_point_operation from_ref(const morpho.duplicate_first_point_operation &ref):
        return _py_duplicate_first_point_operation.from_ptr(<morpho.duplicate_first_point_operation*>&ref)

    @staticmethod
    cdef _py_duplicate_first_point_operation from_value(const morpho.duplicate_first_point_operation &ref):
        cdef morpho.duplicate_first_point_operation *ptr = new morpho.duplicate_first_point_operation(ref)
        return _py_duplicate_first_point_operation.from_ptr(ptr, True)

    @staticmethod
    cdef list vectorPtr2list(std.vector[morpho.duplicate_first_point_operation*] vec):
        return [_py_duplicate_first_point_operation.from_ptr(elem) for elem in vec]

    @staticmethod
    cdef list vector2list(std.vector[morpho.duplicate_first_point_operation] vec):
        return [_py_duplicate_first_point_operation.from_value(elem) for elem in vec]



# ----------------------------------------------------------------------------------------------------------------------
cdef class SpatialIndex(_py__base):
    "Python wrapper class for spatial_index (ns=morpho)"
# ----------------------------------------------------------------------------------------------------------------------
    cdef unique_ptr[morpho.spatial_index] _autodealoc
    cdef morpho.spatial_index *ptr(self):
        return <morpho.spatial_index*> self._ptr

    def __init__(self, ):
        self._ptr = new morpho.spatial_index()
        self._autodealoc.reset(self.ptr())

    def add_morpho_tree(self, MorphoTree tree):
        return self.ptr().add_morpho_tree(tree._sharedPtr)

    def is_within(self, _Point p):
        return self.ptr().is_within(deref(p.ptr()))

    @staticmethod
    cdef SpatialIndex from_ptr(morpho.spatial_index *ptr, bool owner=False):
        cdef SpatialIndex obj = SpatialIndex.__new__(SpatialIndex)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(obj.ptr())
        return obj

    @staticmethod
    cdef SpatialIndex from_ref(const morpho.spatial_index &ref):
        return SpatialIndex.from_ptr(<morpho.spatial_index*>&ref)

    # @staticmethod
    # cdef SpatialIndex from_value(const morpho.spatial_index &ref):
    #     cdef morpho.spatial_index *ptr = new morpho.spatial_index(ref)
    #     return SpatialIndex.from_ptr(ptr, True)

    @staticmethod
    cdef list vectorPtr2list(std.vector[morpho.spatial_index*] vec):
        return [SpatialIndex.from_ptr(elem) for elem in vec]

    # @staticmethod
    # cdef list vector2list(std.vector[morpho.spatial_index] vec):
    #     return [SpatialIndex.from_value(elem) for elem in vec]


## Bindings for class morpho_operation
# ----------------------------------------------------------------------------------------------------------------------
# cdef class _py_morpho_operation(_py__base):
# >> morpho_operation is an abstract class. No need to create bindings
# ----------------------------------------------------------------------------------------------------------------------

## Optional bindings for morpho_mesher, overridable by cython exec
# ----------------------------------------------------------------------------------------------------------------------
DEF ENABLE_MESHER_GCAL = 0
IF ENABLE_MESHER_GCAL:
    include "morpho_mesher.pxi"


# *********************
# Class-Namespace alias
# *********************

cdef class Stats:
    @staticmethod
    def total_number_branches(MorphoTree tree):
        return stats.total_number_branches(deref(tree.ptr()))

    @staticmethod
    def total_number_point(MorphoTree tree):
        return stats.total_number_point(deref(tree.ptr()))

    @staticmethod
    def min_radius_segment(MorphoTree tree):
        return stats.min_radius_segment(deref(tree.ptr()))

    @staticmethod
    def max_radius_segment(MorphoTree tree):
        return stats.max_radius_segment(deref(tree.ptr()))

    @staticmethod
    def median_radius_segment(MorphoTree tree):
        return stats.median_radius_segment(deref(tree.ptr()))

    @staticmethod
    def has_duplicated_points(MorphoTree tree):
        return stats.has_duplicated_points(deref(tree.ptr()))


cdef class Types:
    Point = _Point
    Box = _Box
    Linestring = _Linestring
    Circle = _Circle
    Cone = _Cone
    Sphere = _Sphere
    CurclePipe = _CirclePipe
    PointVector = _PointVector
    MatPoints = _Mat_Points
    MatIndex = _Mat_Index


cdef class Transforms:
    Delete_Duplicate_Point_Operation = _py_delete_duplicate_point_operation
    Duplicate_First_Point_Operation = _py_duplicate_first_point_operation
