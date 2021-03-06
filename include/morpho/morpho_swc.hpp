/*
 * Copyright (C) 2017 Tristan Carel <tristan.carel@epfl.ch>
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
#ifndef MORPHO_TOOLS_MORPHO_READER_SWC_V1
#define MORPHO_TOOLS_MORPHO_READER_SWC_V1

#include "morpho_tree.hpp"
#include "morpho_types.hpp"

namespace morpho {

namespace swc_v1 {

using namespace boost::numeric;

class morpho_reader {
  public:
    morpho_reader(const std::string& filename);

    morpho_tree create_morpho_tree() const;

  private:
    std::string filename;
};

} // namespace morpho
} // namespace swc_v1

#endif // MORPHO_TOOLS_MORPHO_READER_SWC_V1
