template< typename T >
T plus( const &T x )
{
  return -x;
}

template< typename T >
class image
{
public:
  image( const image< T > &_image ) {}
};
