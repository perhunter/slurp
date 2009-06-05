
print prototype( 'CORE::sysread' ), "\n" ;

BEGIN {

  *CORE::GLOBAL::time = sub { CORE::time };
}

print time(), "\n" ;

BEGIN{
local *CORE::GLOBAL::time = sub { 123 };

print time(), "\n" ;
}

print time(), "\n" ;
