//===- llvm/ADT/DenseMapInfo.h - Type traits for DenseMap -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines DenseMapInfo traits for DenseMap.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_ADT_DENSEMAPINFO_H
#define LLVM_ADT_DENSEMAPINFO_H

#include <cstddef>
#include <cstring>

namespace llvm {

template<typename T>
struct DenseMapInfo {
  //static inline T getEmptyKey();
  //static inline T getTombstoneKey();
  //static unsigned getHashValue(const T &Val);
  //static bool isEqual(const T &LHS, const T &RHS);
};

template<>
struct DenseMapInfo<const char *> {
  static inline const char *getEmptyKey() {
    return reinterpret_cast<const char *>(-1);
  }
  static inline const char *getTombstoneKey() {
    return reinterpret_cast<const char *>(-2);
  }
  static unsigned getHashValue(const char *s) {
    size_t hash = sizeof(size_t) == 8 ? size_t{1469598103934665603ULL}
                                     : size_t{2166136261U};
    const size_t prime = sizeof(size_t) == 8 ? size_t{1099511628211ULL}
                                             : size_t{16777619U};
    for (; *s; ++s) {
      hash ^= static_cast<unsigned char>(*s);
      hash *= prime;
    }
    return static_cast<unsigned>(hash ^ (hash >> 32));
  }
  static bool isEqual(const char *LHS, const char *RHS) {
    if (LHS == RHS)
      return true;
    if (LHS == getEmptyKey() || RHS == getEmptyKey())
      return false;
    if (LHS == getTombstoneKey() || RHS == getTombstoneKey())
      return false;
    return std::strcmp(LHS, RHS) == 0;
  }
};


} // end namespace llvm

#endif // LLVM_ADT_DENSEMAPINFO_H
