from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector
from libc.stdio cimport sprintf, printf
from cpython cimport PyObject, Py_INCREF
import numpy as np
cimport numpy as np

# We need to initialize NumPy.
np.import_array()

# cython hack for having integer template
cdef extern from *:
    ctypedef int zero_t "0"
    ctypedef int one_t "1"

ctypedef unsigned int uint

# ----------------------------------------------------------------------------------------------------------------------
cdef class _Point(_py__base):
    cdef unique_ptr[morpho.point] _autodealoc
    cdef morpho.point* ptr(self):
        return <morpho.point *> self._ptr

    def __init__(self, double x, double y, double z):
        self._ptr = new morpho.point(x, y, z)
        self._autodealoc.reset(self.ptr())

    def close_to(self, _Point other):
        return self.ptr().close_to(deref(other.ptr()))

    def __getitem__(self, unsigned int item):
        assert item <= 2, IndexError(item)
        cdef const double *_data = self.ptr().data()
        return _data[item]

    def __setitem__(self, unsigned int item, double value):
        assert item <= 2, IndexError(item)
        cdef double *_data = <double *> self.ptr().data()
        _data[item] = value

    def as_tuple(self):
        cdef double *_data = <double *> self.ptr().data()
        return (_data[0], _data[1], _data[2])

    @property
    def nparray(self):
        cdef double * _data = <double*> self.ptr().data()
        cdef np.npy_intp dim = 3
        return _ArrayT.nparray_create(1, &dim, np.NPY_DOUBLE, _data)

    def __str__(self):
        cdef double * _data = <double *> self.ptr().data()
        cdef char outstr[30]
        sprintf(outstr, "(%.3lf, %.3lf, %.3lf)", _data[0], _data[1], _data[2])
        return outstr

    def __repr__(self):
        return "<_Point" + str(self) + ">"

    @staticmethod
    cdef _Point from_ptr(morpho.point* ptr, bool owner=False):
        cdef _Point obj = _Point.__new__(_Point)
        obj._ptr = ptr
        if owner:
            obj._autodealoc.reset(obj.ptr())
        return obj

    @staticmethod
    cdef _Point from_value(const morpho.point &ref):
        cdef morpho.point *p = new morpho.point(ref)
        return _Point.from_ptr(p, True)


# ----------------------------------------------------------------------------------------------------------------------
cdef class _Box(_py__base):
    cdef unique_ptr[morpho.box] _autodealoc
    cdef morpho.box* ptr(self):
        return < morpho.box * > self._ptr

    def __repr__(self):
        return "<_Box [%s - %s]>" % (str(self.min_corner), str(self.max_corner))

    @property
    def min_corner(self):
        return _Point.from_value(self.ptr().min_corner())

    @property
    def max_corner(self):
        return _Point.from_value(self.ptr().max_corner())

    @staticmethod
    cdef _Box from_ptr(morpho.box *ptr, bool owner=False):
        cdef _Box obj = _Box.__new__(_Box)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(ptr)
        return obj

    @staticmethod
    cdef _Box from_value(const morpho.box &ref):
        cdef morpho.box *ptr = new morpho.box(ref)
        return _Box.from_ptr(ptr, True)


# ----------------------------------------------------------------------------------------------------------------------
cdef class _Linestring(_py__base):
    cdef unique_ptr[morpho.linestring] _autodealoc
    cdef morpho.linestring * ptr(self):
        return < morpho.linestring *> self._ptr

    @staticmethod
    cdef _Linestring from_ptr(morpho.linestring *ptr, bool owner=False):
        cdef _Linestring obj = _Linestring.__new__(_Linestring)
        obj._ptr = ptr
        # _ArrayT was giving problems with the numpy array
        # #Create np array
        # cdef np.npy_intp size[2]
        # size[0] = ptr.size()
        # size[1] = 3
        # obj.nparray = np.PyArray_SimpleNewFromData(2, size, np.NPY_DOUBLE, ptr.data())
        if owner: obj._autodealoc.reset(ptr)
        return obj

    @staticmethod
    cdef _Linestring from_value(const morpho.linestring &ref):
        cdef morpho.linestring* ptr = new morpho.linestring(ref)
        return _Linestring.from_ptr(ptr, True)


# ----------------------------------------------------------------------------------------------------------------------
cdef class _Circle(_py__base):
    cdef unique_ptr[morpho.circle] _autodealoc
    cdef morpho.circle * ptr(self):
        return < morpho.circle *> self._ptr

    def __repr__(self):
        return "<_Circle: pos %s, radius %.3f>" % (str(self.center), self.radius)

    @property
    def center(self):
        return _Point.from_value(self.ptr().get_center())

    @property
    def radius(self):
        return self.ptr().get_radius()

    @staticmethod
    cdef _Circle from_ptr(morpho.circle *ptr, bool owner=False):
        cdef _Circle obj = _Circle.__new__(_Circle)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(ptr)
        return obj

    @staticmethod
    cdef _Circle from_ref(const morpho.circle &ref):
        return _Circle.from_ptr(<morpho.circle*>&ref)

    @staticmethod
    cdef _Circle from_value(const morpho.circle &ref):
        cdef morpho.circle* ptr = new morpho.circle(ref)
        return _Circle.from_ptr(ptr, True)


# ----------------------------------------------------------------------------------------------------------------------
cdef class _Cone(_py__base):
    cdef unique_ptr[morpho.cone] _autodealoc
    cdef morpho.cone * ptr(self):
        return <morpho.cone *> self._ptr

    @property
    def center0(self):
        return _Point.from_value(self.ptr().get_center[zero_t]())

    @property
    def radius0(self):
        return self.ptr().get_radius[zero_t]()

    @property
    def center1(self):
        return _Point.from_value(self.ptr().get_center[one_t]())

    @property
    def radius1(self):
        return self.ptr().get_radius[one_t]()

    @staticmethod
    cdef _Cone from_ptr(morpho.cone *ptr, bool owner=False):
        cdef _Cone obj = _Cone.__new__(_Cone)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(ptr)
        return obj

    @staticmethod
    cdef _Cone from_value(const morpho.cone &ref):
        cdef morpho.cone* ptr = new morpho.cone(ref)
        return _Cone.from_ptr(ptr, True)


# ----------------------------------------------------------------------------------------------------------------------
cdef class _Sphere(_py__base):
    cdef unique_ptr[morpho.sphere] _autodealoc
    cdef morpho.sphere * ptr(self):
        return < morpho.sphere *> self._ptr

    def __init__(self, point, double radius):
        if isinstance(point, _Point):
            self._ptr = new morpho.sphere(deref((<_Point>point).ptr()), radius)
        else:
            self._ptr = new morpho.sphere(morpho.point(point[0], point[1], point[2]), radius)
        self._autodealoc.reset(self.ptr())

    def __repr__(self):
        return "<_Sphere: center %s, radius %.3f" % (self.center, self.radius)

    @property
    def center(self):
        return _Point.from_value(self.ptr().get_center())

    @property
    def radius(self):
        return self.ptr().get_radius()

    @staticmethod
    cdef _Sphere from_ptr(morpho.sphere *ptr, bool owner=False):
        cdef _Sphere obj = _Sphere.__new__(_Sphere)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(ptr)
        return obj

    @staticmethod
    cdef _Sphere from_value(const morpho.sphere &ref):
        cdef morpho.sphere* ptr = new morpho.sphere(ref)
        return _Sphere.from_ptr(ptr, True)



# ----------------------------------------------------------------------------------------------------------------------
# _Circle pipe
#  - This class is somewhat special in the sense that it represents a Vector of circles
#  - However circles are not stack-alloc'able in Cyhton (no default ctor) so we cant iterate
# over them directly to create a list
#  - Therefore we implemented array and iterator interface by getting the elements from their address and wrapping
# in their corresponding Python class, which is executed the exact moment the object is required.
#  - By using this technique, the circle_pipe can be passed on to another function without even incurring
# wrapping/unwrapping of its elements
# ----------------------------------------------------------------------------------------------------------------------
cdef class _CirclePipe(_py__base):
    cdef unique_ptr[morpho.circle_pipe] _autodealoc
    cdef morpho.circle_pipe * ptr(self):
        return < morpho.circle_pipe *> self._ptr

    # Pass on the array API
    def __getitem__(self, int index):
        if index >= len(self) or index < 0:
            raise IndexError("_Circle pipe object is %d circles long. Requested:%d"%(len(self), index))
        cdef vector[morpho.circle] *cp = <vector[morpho.circle]*>self._ptr
        cdef morpho.circle * mcircle = cp.data()
        # This circle doesnt own C data, we lend him memory from the vector
        return _Circle.from_ptr( &mcircle[index] )

    def __repr__(self):
        cdef int i, lim = min(3, len(self))
        return "<CirclePipe object. Length: %d>" % (len(self),)

    def __iter__(self):
        cdef int i
        #Generator is also iterator
        return (self[i] for i in range(len(self)))

    def __len__(self):
        return self.ptr().size()

    def size(self):
        print("Info: the current object implements iterator and array interface. use len(obj) instead of .size()")
        return len(self)

    @staticmethod
    cdef _CirclePipe from_ptr(morpho.circle_pipe *ptr, bool owner=False):
        cdef _CirclePipe obj = _CirclePipe.__new__(_CirclePipe)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(ptr)
        return obj

    @staticmethod
    cdef _CirclePipe from_value(const morpho.circle_pipe &ref):
        cdef morpho.circle_pipe* ptr = new morpho.circle_pipe(ref)
        return _CirclePipe.from_ptr(ptr, True)


# ----------------------------------------------------------------------------------------------------------------------
cdef class _PointVector(_ArrayT):
    #Numpy array object
    cdef vector[morpho.point] * ptr(self):
        return <vector[morpho.point] *> self._ptr

    def __init__(self, double[:,:] ptsVector):
        self._ptr = new vector[morpho.point]()
        cdef double [:] pt
        for pt in ptsVector:
            self.ptr().push_back(morpho.point(pt[0],pt[1], pt[2]))

        cdef np.npy_intp size[2]
        size[0] = ptsVector.shape[0]
        size[1] = 3
        self.init_nparray(2, size, np.NPY_DOUBLE, <void*>self.ptr().data().data())

    def __repr__(self):
        cdef int i, lim = min(3, len(self))
        return "<PointVector object. Length: %d>" % (len(self),)

    # Pass on the array API
    def __getitem__(self, index):
        if isinstance(index, int):
            return self.get_point(index)
        return self.nparray[index]

    def get_point(self, int index):
        if index >= len(self) or index < 0:
            raise IndexError("Length is %d. Requested:%d"%(len(self), index))
        cdef morpho.point * point0 = self.ptr().data()
        # This point doesnt own C data, we lend him memory from the vector
        return _Point.from_ptr(&point0[index])

    def __iter__(self):
        cdef int i
        #Generator is also iterator
        return (self[i] for i in range(len(self)))

    @property
    def size(self):
        return len(self)

    @staticmethod
    cdef _PointVector from_ptr(const vector[morpho.point] *ptr):
        cdef _PointVector obj = _PointVector.__new__(_PointVector)
        obj._ptr = <vector[morpho.point] *>ptr
        #NumPy Array
        cdef np.npy_intp size[2]
        size[0] = ptr.size()
        size[1] = 3
        obj.init_nparray(2, size, np.NPY_DOUBLE, <void*>ptr.data().data())
        return obj

    @staticmethod
    cdef _PointVector from_ref(const vector[morpho.point] &ref):
        return _PointVector.from_ptr(&ref)


# ----------------------------------------------------------------------------------------------------------------------
# Main Data Structures
# ----------------------------------------------------------------------------------------------------------------------

cdef class _Mat_Points(_ArrayT):
    cdef unique_ptr[morpho.mat_points] _autodealoc
    cdef morpho.mat_points * ptr(self):
        return <morpho.mat_points *> self._ptr

    @staticmethod
    cdef _Mat_Points from_ptr(morpho.mat_points * matpoints, bool owner=False):
        cdef _Mat_Points obj = _Mat_Points()
        obj._ptr = matpoints
        if owner: obj._autodealoc.reset(matpoints)

        # Create a numpy array (memviews dont expose so nicely to python)
        cdef np.npy_intp size[2]
        size[0] = matpoints.size1()
        size[1] = matpoints.size2()
        obj.init_nparray(2, size, np.NPY_DOUBLE, matpoints.data().begin())

        return obj


    @staticmethod
    cdef _Mat_Points from_ref(const morpho.mat_points &ref):
        return _Mat_Points.from_ptr(<morpho.mat_points*>&ref)

    @staticmethod
    cdef _Mat_Points from_value(const morpho.mat_points &ref):
        cdef morpho.mat_points* ptr = new morpho.mat_points(ref)
        return _Mat_Points.from_ptr(ptr, True)


# ----------------------------------------------------------------------------------------------------------------------
cdef class _Mat_Index(_ArrayT):
    cdef unique_ptr[morpho.mat_index ] _autodealoc
    cdef morpho.mat_index* ptr(self):
        return <morpho.mat_index *> self._ptr

    @staticmethod
    cdef _Mat_Index from_ptr(morpho.mat_index *ptr, bool owner=False):
        cdef _Mat_Index obj = _Mat_Index.__new__(_Mat_Index)
        obj._ptr = ptr
        if owner: obj._autodealoc.reset(ptr)
        # Create a numpy array
        cdef np.npy_intp[2] dim
        dim[0] = ptr.size1()
        dim[1] = ptr.size2()
        obj.init_nparray(2, dim, np.NPY_INT, ptr.data().begin())
        return obj

    @staticmethod
    cdef _Mat_Index from_ref(const morpho.mat_index &ref):
        return _Mat_Index.from_ptr(<morpho.mat_index*>&ref)

    @staticmethod
    cdef _Mat_Index from_value(const morpho.mat_index &ref):
        cdef morpho.mat_index *ptr = new morpho.mat_index(ref)
        return _Mat_Index.from_ptr(ptr, True)



# ************************************
# Class-Namespace alias
# ************************************

class Types:
    Point = _Point
    Box = _Box
    Linestring = _Linestring
    Circle = _Circle
    Cone = _Cone
    Sphere = _Sphere
    CirclePipe = _CirclePipe
    PointVector = _PointVector
    MatPoints = _Mat_Points
    MatIndex = _Mat_Index
