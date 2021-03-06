%define name sextractor
%define version 2.5.0
%define release 1

Summary: Extract catalogs of sources from astronomical images
Name: %{name}
Version: %{version}
Release: %{release}
Source0: ftp://ftp.iap.fr/pub/from_users/bertin/sextractor/%{name}-%{version}.tar.gz
URL: http://terapix.iap.fr/soft/%{name}
License: LGPL
Group: Sciences/Astronomy
BuildRoot: %{_tmppath}/%{name}-buildroot
Prefix: %{_prefix}

%description
SExtractor stands for ``Source Extractor'': a software for making catalog of sources from astronomical images.

%prep
%setup -q

%build
if test "$GCCFLAGS"; then
./configure --enable-static --prefix=$RPM_BUILD_ROOT/usr/local/ --mandir=$RPM_BUILD_ROOT/usr/local/man/
make CFLAGS="$GCCFLAGS"
else
./configure --prefix=$RPM_BUILD_ROOT/usr/local/ --mandir=$RPM_BUILD_ROOT/usr/local/man/
make
fi

%install
make install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
/usr/local/bin/sex
/usr/local/man/man1/sex.1
/usr/local/man/manx/sex.x
%doc AUTHORS BUGS ChangeLog COPYING HISTORY INSTALL README THANKS doc/README.DOC doc/sextractor.pdf

%changelog
* Wed Jan 09 2019 Emmanuel Bertin <bertin@iap.fr>
- Automatic RPM rebuild
* Tue May 13 2003 Emmanuel Bertin <bertin@iap.fr>
- RPM build for V2.3
* Fri Apr 04 2003 Emmanuel Bertin <bertin@iap.fr>
- RPM build for V2.3b4
* Wed Mar 05 2003 Emmanuel Bertin <bertin@iap.fr>
- RPM build for V2.3b3
* Fri Feb 07 2003 Emmanuel Bertin <bertin@iap.fr>
- Second RPM build
* Fri Jan 24 2003 Emmanuel Bertin <bertin@iap.fr>
- Second RPM build
* Sun Dec 15 2002 Emmanuel Bertin <bertin@iap.fr>
- First RPM build

# end of file
