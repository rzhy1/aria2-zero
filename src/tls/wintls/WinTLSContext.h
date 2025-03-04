/* <!-- copyright */
/*
 * aria2 - The high speed download utility
 *
 * Copyright (C) 2013 Nils Maier
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * In addition, as a special exception, the copyright holders give
 * permission to link the code of portions of this program with the
 * OpenSSL library under certain conditions as described in each
 * individual source file, and distribute linked combinations
 * including the two.
 * You must obey the GNU General Public License in all respects
 * for all of the code used other than OpenSSL.  If you modify
 * file(s) with this exception, you may extend this exception to your
 * version of the file(s), but you are not obligated to do so.  If you
 * do not wish to do so, delete this exception statement from your
 * version.  If you delete this exception statement from all source
 * files in the program, then also delete it here.
 */
/* copyright --> */

#ifndef D_WIN_TLS_CONTEXT_H
#define D_WIN_TLS_CONTEXT_H

#include "common.h"
#include "config.h"

#include <string>

#include <subauth.h>
#include <windows.h>
#include <security.h>
#include <schnlsp.h>

#include "TLSContext.h"
#include "DlAbortEx.h"

namespace aria2 {

namespace wintls {
struct cred_deleter {
  void operator()(CredHandle* handle)
  {
    if (handle) {
      FreeCredentialsHandle(handle);
      delete handle;
    }
  }
};
typedef std::unique_ptr<CredHandle, cred_deleter> CredPtr;
} // namespace wintls

class WinTLSContext : public TLSContext {
public:
  WinTLSContext(TLSSessionSide side, TLSVersion ver);

  virtual ~WinTLSContext();

  // private key `keyfile' must be decrypted.
  virtual bool addCredentialFile(const std::string& certfile,
                                 const std::string& keyfile) CXX11_OVERRIDE;

  virtual bool addSystemTrustedCACerts() CXX11_OVERRIDE { return true; }

  // certfile can contain multiple certificates.
  virtual bool addTrustedCACertFile(const std::string& certfile) CXX11_OVERRIDE;

  virtual bool good() const CXX11_OVERRIDE { return true; }

  virtual TLSSessionSide getSide() const CXX11_OVERRIDE { return side_; }

  virtual bool getVerifyPeer() const CXX11_OVERRIDE;

  virtual void setVerifyPeer(bool verify) CXX11_OVERRIDE;

  CredHandle* getCredHandle();

  static bool isTLS13Supported();
private:
  TLSSessionSide side_;
  DWORD credentialsFlags_;
  int enabled_protocols_;
  HCERTSTORE store_;
  wintls::CredPtr cred_;
};

} // namespace aria2

#endif // D_LIBSSL_TLS_CONTEXT_H
