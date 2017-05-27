"""

x,w,T = nfieldtrans(n,M,basis)

Constructs transforms and associated arrays for precise numerical quadrature evaluation of n-field integrals,
starting from a representation of the quantum state with respect to a particular basis of eigenstates.

# Arguments
 - `n` order of the field product.
 - `M` number of modes in the c-field.
 - `basis` is an optional string argument denoting the basis of eigenstates representing c-field state. Default is "hermite"
 - `T` is the linear transformation matrix that affects the mapping
 
`T*c` = `` ψ(x)≡ ∑_{j=1}^{M}c_jϕ_j(x)``

for a state represented by `M` coefficients, the number of modes in the c-field.
 - `x` is the quadrature grid onto which ``ψ(x)`` is mapped
 - `w` are weights such that the an exact integral may be carreid out.
The integral must be a product of order `n` in the field ``ψ``, and it is assumed that `n` is even.

The integrals is performed by
1. Transforming to the quadrature grid using `T`
2. Constructing the product and then evaluating the sum: `∑ⱼwⱼ*ψ(xⱼ)ⁿ=sum(w*ψ^n)`

# Examples

## C-field population
Compute the number of particles in the C-field, for a state of `M` modes.

```
julia> M = 30;
julia> c = randn(M)+im*randn(M);
julia> x,w,T=nfieldtrans(2,M);
julia> ψ = T*c;
julia> N = sum(w*abs(ψ).^2)
73.24196674113007
```

Compuates the integral ``N = ∫dx |ψ(x)|^2`` as may be checked by direct summation:

```
julia> sum(abs(c).^2)
73.24196675017353
```

The accuracy seen in this example (10 digits) is a worst-case scenario - a random superposition of all modes is a high temperature limit.
Accuracy will normally approach 16 digits.

## Interaction energy
The most common integral of this type involves a four-field product, `n=4`.
The PGPE interaction energy is of this form, as is the nonlinear term in the PGPE;
the exact propagation of the PGPE requires repeated use of this 4-field transformation:

```
julia> x,w,T=nfieldtrans(4,M);
julia> ψ = T*c;
julia> Uint = sum(w*abs(ψ).^4)
552.9762736751692
```
computes the integral ``U_{\int}≡∫ dx|ψ|^4`` to accuracy very close to working precision.

**Warning:** Using the transform `T` for physical analysis in position space should be avoided
as the `x` grid is non-uniformly spaced.
Instead, use `eigmat.jl` to create a transform to a specific position grid.
"""

function nfieldtrans(n::Int,M::Int,basis="hermite")
   (iseven(n) && n > 0) ? J = Int(n/2) : error("n must be a positive and even integer ")
    if basis=="hermite"
    x, w = gausshermite(J*M)
    T    = eigmat("hermite",M,x/sqrt(J))
    w    = w.*exp(x.^2)/sqrt(J)
    return x,w,T
    else
        error(basis," basis not implemeted yet.")
    end
end