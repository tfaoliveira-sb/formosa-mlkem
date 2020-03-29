require import List Int IntExtra IntDiv CoreMap IntDiv.
from Jasmin require  import JModel JMemory.

(*
MOVE ELSEWHERE
*)

lemma to_sintD_small : (forall (a b : W16.t), 
    -W16.modulus %/2 <= to_sint a + to_sint b < W16.modulus %/2 =>
    to_sint (a + b) = to_sint a + to_sint b).
proof. 
move => a b.
  rewrite !W16.to_sintE !/smod => />.
  move : (W16.to_uint_cmp a). 
  move : (W16.to_uint_cmp b). 
  case(32768 <= to_uint a).
  case(32768 <= to_uint b).
  move => /> *.  
  rewrite (_:  to_uint (a + b)= (to_uint a +  to_uint b) - 65536).
  rewrite to_uintD => />;   smt(@W16).  smt(@W16).
  move => /> *. 
  case (65536  <= to_uint a + to_uint b).
  move => *.
  rewrite (_:  to_uint (a + b)= (to_uint a +  to_uint b) - 65536).
  rewrite to_uintD => />;   smt(@W16).  smt(@W16).
  move => *.  
  rewrite to_uintD_small => />;   smt(@W16).  
  move => /> *. 
  case (65536  <= to_uint a + to_uint b).
  move => *.
  rewrite (_:  to_uint (a + b)= (to_uint a +  to_uint b) - 65536).
  rewrite to_uintD => />;   smt(@W16).  smt(@W16).
  move => *.  
  rewrite to_uintD_small => />;   smt(@W16).  
qed.


lemma to_sintB_small : (forall (a b : W16.t), 
    -W16.modulus %/2 <= to_sint a - to_sint b < W16.modulus %/2 =>
    to_sint (a - b) = to_sint a - to_sint b).
proof.
move => a b.
  rewrite !W16.to_sintE !/smod => />.
  move : (W16.to_uint_cmp a). 
  move : (W16.to_uint_cmp b). 
  case (to_uint b <= to_uint a).
  move => /> *.  
  case(32768 <= to_uint a).
  rewrite (_:  to_uint (a - b)= (to_uint a -  to_uint b)); smt(@W16 @IntDiv).
  rewrite (_:  to_uint (a - b)= (to_uint a -  to_uint b)); smt(@W16 @IntDiv).
  move => /> *.  
  case(32768 <= to_uint a).
  case(32768 <= to_uint b).
  move => /> *.  
  rewrite (_:  to_uint (a - b)= (to_uint a -  to_uint b) + 65536).
  rewrite to_uintD to_uintN => />;  smt(@W16 @IntDiv). smt(@W16 @IntDiv).
  move => /> *.  
  rewrite (_:  to_uint (a - b)= (to_uint a -  to_uint b) + 65536).
  rewrite to_uintD to_uintN => />;  smt(@W16 @IntDiv). smt(@W16 @IntDiv).
  move => /> *.  
  rewrite (_:  to_uint (a - b)= (to_uint a -  to_uint b) + 65536).
  rewrite to_uintD to_uintN => />;  smt(@W16 @IntDiv). smt(@W16 @IntDiv).
qed.

lemma to_sintM_small : (forall (a b : W16.t), 
    -W16.modulus %/2 <= to_sint a * to_sint b < W16.modulus %/2 =>
    to_sint (a * b) = to_sint a * to_sint b).
proof.
move => a b.
  rewrite !W16.to_sintE !/smod => />.
  move : (W16.to_uint_cmp a). 
  move : (W16.to_uint_cmp b). 
  case(32768 <= to_uint a).
  case(32768 <= to_uint b).
  move => /> *; smt(@W16).
  move => *.
  case (65536  <= to_uint a * to_uint b).
  rewrite to_uintM  => />;  smt(@W16 @IntDiv). 
  smt(@W16 @IntDiv).
  move => *.
  case(32768 <= to_uint b).
  case (65536  <= to_uint a * to_uint b).
  move => *.
  rewrite to_uintM  => />;  smt(@W16 @IntDiv). 
  smt(@W16 @IntDiv).
  rewrite to_uintM  => />;  smt(@W16 @IntDiv). 
qed.

(*
END MOVE ELSEWHERE
*)

require import Poly.
require import Fq.

theory R256.

op n : int =  256 axiomatized by nE.
op e : int = 17 axiomatized by eE.

clone include PolyQPrincipalIdeal
  with type elem <- Fq.ZModP.zmod,
         op Poly.Elem.zeror  <- Fq.ZModP.zero ,
         op Poly.Elem.oner   <- Fq.ZModP.one  ,
         op Poly.Elem.( + )  <- Fq.ZModP.( + ),
         op Poly.Elem.([-])  <- Fq.ZModP.([-]),
         op Poly.Elem.( * )  <- Fq.ZModP.( * ),
         op Poly.Elem.invr   <- Fq.ZModP.inv  ,
       pred Poly.Elem.unit   <- Fq.ZModP.unit ,
         op P                <- Poly.( + ) (Poly.exp Poly.X n)  Poly.one.

end R256.

export R256.

theory KyberPoly.

import Fq.
import ZModP.

op q = W16.of_int 3329 axiomatized by qE.

op bw16 (a : W16.t) i =
     0 <= i <= 15 /\ (* signed 15 bits at most *)
     -2^i <= to_sint a < 2^i.

op add (a b : W16.t) = (a + b).

lemma add_corr (a b : W16.t) (a' b' : zmod) (asz bsz : int): 
   asz < 15 => bsz < 15 =>
   a' = inzmod (W16.to_sint a) =>
   b' = inzmod (W16.to_sint b) =>
   bw16 a asz => 
   bw16 b bsz =>
     inzmod (W16.to_sint (add a b)) = a' + b' /\
           bw16 (add a b) (max asz bsz + 1).
proof.

rewrite /bw16 /add  => />.
pose aszb := 2^asz.
pose bszb := 2^bsz.
move => ?? ?? [#?] ?? [#?] ??.

have bounds_asz : 0 < aszb <= 16384; first by split; [ apply gt0_pow2 | move => *; apply (pow_Mle asz 14 _) => /# ].
have bounds_bsz : 0 < bszb <= 16384; first by split; [ apply gt0_pow2 | move => *; apply (pow_Mle bsz 14 _) => /#].

rewrite !to_sintD_small; first by smt().

split; first by smt(@ZModP).
split; first by smt().

case ( max asz bsz = asz).
move => *; rewrite H9. 
rewrite (_: 2^(asz + 1) = aszb * 2). smt(@IntExtra). 
have ? : (- aszb  <= to_sint b); smt(@W16 @IntExtra).

move => *. rewrite (_: max asz bsz = bsz). smt(). 
rewrite (_: 2^(bsz + 1) = bszb * 2). smt(@IntExtra). 
have ? : (- bszb  <= to_sint a); smt(@W16 @IntExtra).
qed.

import Fq.SignedReductions.
(*
op mul (a b : W16.t) = W16.of_int (SREDC (W32.to_uint (sigextu32 a * sigextu32 b))).

lemma mul_corr (a b : W16.t) (a' b' : zmod) (asz bsz : int): 
   asz < 15 => bsz < 15 =>
   a' = inzmod (W16.to_sint a) =>
   b' = inzmod (W16.to_sint b) =>
   bw16 a asz => 
   bw16 b bsz =>
     inzmod (W16.to_sint (add a b)) = a' + b' /\
           bw16 (add a b) (max asz bsz + 1).
proof.

rewrite /bw16 /add  => />.
pose aszb := 2^asz.
pose bszb := 2^bsz.
move => ?? ?? [#?] ?? [#?] ??.

have bounds_asz : 0 < aszb <= 16384; first by split; [ apply gt0_pow2 | move => *; apply (pow_Mle asz 14 _) => /# ].
have bounds_bsz : 0 < bszb <= 16384; first by split; [ apply gt0_pow2 | move => *; apply (pow_Mle bsz 14 _) => /#].

rewrite !to_sintD_small; first by smt().

split; first by smt(@ZModP).
split; first by smt().

case ( max asz bsz = asz).
move => *; rewrite H9. 
rewrite (_: 2^(asz + 1) = aszb * 2). smt(@IntExtra). 
have ? : (- aszb  <= to_sint b); smt(@W16 @IntExtra).

move => *. rewrite (_: max asz bsz = bsz). smt(). 
rewrite (_: 2^(bsz + 1) = bszb * 2). smt(@IntExtra). 
have ? : (- bszb  <= to_sint a); smt(@W16 @IntExtra).
qed.*)


require import NTT_Fq.

clone import NTT_Fq with
   op ZModP.p <- Fq.q,
   type ZModP.zmod <- zmod,
   op ZModP.zero  <- Fq.ZModP.zero,
   op ZModP.one   <- Fq.ZModP.one  ,
   op ZModP.( + )  <- Fq.ZModP.( + ),
   op ZModP.([-])  <- Fq.ZModP.([-]),
   op ZModP.( * )  <- Fq.ZModP.( * ),
   op ZModP.inv   <- Fq.ZModP.inv  ,
   op ZModP.inzmod <- inzmod,
   op ZModP.asint <- asint. (* .. *)

require import Poly_ntt.
print M.

require import Array256.

print M.

lemma poly_reduct_corr:
    forall (_a : int Array256.t),
      phoare[ M.poly_reduce :
           (forall i, 0<= i < 256 =>
              (to_sint rp.[i]) = _a.[i]) ==> 
           forall i, 0<= i < 256 =>
              to_sint res.[i] = BREDC _a.[i] 26]= 1%r.
proof.
move => _a.
proc.
while (0 <= to_uint j <= 256 /\ 
       (forall k, 0 <= k < to_uint j => to_sint rp.[k] = (BREDC _a.[k] 26)) /\
       (forall k, to_uint j <= k < 256 => to_sint rp.[k] =  _a.[k]))
       (256 - to_uint j) ; last first.
auto => />. 
move => &ht H.
split; first by smt().
move => *. 
move : H; rewrite ultE of_uintK => />; smt(@W16 @W64).
move => *.
wp. sp.
exists* t, j.
elim* => t j.
print barret_reduct_corr.
call (barret_reduct_corr _a.[to_uint j]).
by auto => />;smt(@W64 @Array256).
qed.

op lift_array (p : W16.t Array256.t) =
  Array256.map (fun x => inzmod (W16.to_sint x)) p.

op array_mont (p : zmod Array256.t) =
  Array256.map (fun x => x *  (inzmod R)) p.

op load_array_from_mem(mem : global_mem_t, ptr : W64.t) : W16.t Array256.t.

axiom load_array_from_memE mem ptr i :
   0 <= i < 256 =>
     loadW16 mem (W64.to_uint ptr + 2* i) = (load_array_from_mem mem ptr).[i].

op ntt_bound_zetas(zetas : W16.t Array256.t) : bool =
   forall k, 0 <= k < 256 => 0 <= to_sint zetas.[k] < Fq.q-1.

op log2(n : int) : int.

(* TODO: use easycrypt's native log to base *)
axiom log2E n l :
   0 <= l => n = 2^l => log2 n = l.

axiom log2pos n :
   1 <= n => 0 <= log2 n.


lemma logs :
   log2 128 = 7 /\
   log2 64  = 6 /\
   log2 32  = 5 /\
   log2 16  = 4 /\
   log2 8   = 3 /\
   log2 4   = 2 /\
   log2 2   = 1 /\
   log2 1   = 0
  by smt(pow0 pow2_1 pow2_2 pow2_3 pow2_4 pow2_5 pow2_6 pow2_7  log2E log2pos).

lemma logdiv2 n l :
  1 < n =>
  n = 2^l =>
  log2 (n %/2) = log2 n -1
   by smt(@IntExtra log2E). 


op ntt_bound_coefs(coefs : W16.t Array256.t, c : int) : bool =
   forall k, 0 <= k < 256 => -c*Fq.q <= to_sint coefs.[k] <= c*Fq.q.


equiv ntt_correct &m :
  NTT_Fq.NTT.ntt ~ M.poly_ntt : 
        to_uint zetasp{2}  < W64.modulus - 514 /\
        r{1} = lift_array rp{2} /\ 
        array_mont zetas{1} = 
           lift_array (load_array_from_mem Glob.mem{2} zetasp{2}) /\
        ntt_bound_zetas (load_array_from_mem Glob.mem{2} zetasp{2}) /\
        ntt_bound_coefs rp{2} 2
          ==> 
            res{1} = lift_array res{2} /\
            all (fun x => 0<= W16.to_sint x < 2*Fq.q) res{2}.
proc.
(* Dealing with final barret reduction *)
seq 3 2 :  (forall k, 0 <= k < 256 => r{1} = lift_array rp{2}); last first.
exists * r{1}, rp{2}.
elim* => r1 rp2.
call {2} (_:  
     forall i, 0 <= i < 256 =>
             to_sint rp.[i] = (map (fun (x : W16.t) => to_sint x) rp2).[i]
     ==> 
     forall i, 0 <= i < 256 =>
             to_sint res.[i] =
             BREDC (map (fun (x : W16.t) => to_sint x) rp2).[i] 26). 
apply (poly_reduct_corr (Array256.map (fun x => (W16.to_sint x)) rp2)).
skip. move => &1 &2 [#] ???.
split.
move => i ibnd; first by smt (@Array256).
move => ???.
have bnds : (
 forall (k : int),
      0 <= k < 256 =>
      -32768 <= to_sint rp{2}.[k] < 32768
). 
move => k kb. rewrite to_sintE /smod => />. 
move : (W16.to_uint_cmp ( rp{2}.[k]));smt().
split.

+ rewrite (Array256.ext_eq r{1} (lift_array result)) //=.
   move => x xb;rewrite /lift_array  mapiE //=  (H3 x xb) mapiE => />.
   move : (BREDCp_corr (to_sint rp2.[x]) 26 _ _ _ _ _);
      first 5 by smt(@Fq).  
   move : (H1 x xb);rewrite Array256.tP => [# ] ? [#] ???.
   move : (H4 x xb);rewrite /lift_array mapiE => /> *;smt(@ZModP).
+ rewrite allP => i ib />.  
  rewrite  (H3 i ib) mapiE => />.
  move : (BREDCp_corr (to_sint rp2.[i]) 26 _ _ _ _ _);smt(@Fq @ZModP).
(***********************************)

sp.
exists *zetasp{2}.
elim* => zetasp2.
while (
   to_uint zetasp{2} + 512 - (k{1}-1)*2 < W64.modulus /\
   r{1} = lift_array rp{2} /\
   array_mont zetas{1} = lift_array
              (load_array_from_mem Glob.mem{2} zetasp2) /\
   len{1} = to_uint len{2} /\
   (exists l, 0 <= l <= 7 /\ len{1} = 2^l) /\
   1 <= k{1} <= 256 /\
   to_uint zetasp{2} = to_uint zetasp2 + (k{1}-1)*2 /\
   2*k{1}*len{1} = 256 /\
   ntt_bound_zetas (load_array_from_mem Glob.mem{2} zetasp2) /\ 
   ntt_bound_coefs rp{2} (9 - log2 len{1})); last by  auto => />; smt.
wp.
exists* k{1}.
elim* => k1.
move  => l.
while (#{/~k1=k{1}}
        {~2*k{1}*len{1} = 256}
        {~ntt_bound_coefs rp{2} (256 %/ len{1})}pre /\ 
       2*k1*len{1}= 256 /\
       start{1} = to_uint start{2} /\
       0 <= start{1} <= 256 /\
       start{1} = 2*(k{1} - k1)*len{1} /\
       2* (k{1} - k1) * to_uint len{2} <= 256 /\
       (* Nasty carry inv *)
       ntt_bound_coefs rp{2} (9 - log2 len{1} + 1) /\
       forall k st,
          0 <= k < 256 =>
          st <= start{1} < 256 =>
          st <= k < st+2*len{1} =>
            ntt_bound_coefs rp{2} (9 - log2 len{1})
       ); last first.
 auto => />; move => *.
split; first by smt(@W16 @Array256 @Fq).
move => *.
rewrite uleE !shr_div.
split; last  by smt(@W64).
split; first  by smt(@W64).
split; first by  exists (l-1); smt(@IntExtra).
split; first  by smt(@W64). 
rewrite (logdiv2 (to_uint len{2}) (log2 (to_uint len{2}))). smt(@W16). 
 smt. (* mistery *)
by smt(@W16 @Array256 @Fq).

wp.
while (#{/~start{1} = 2*(k{1} - k1) * len{1}}
        {~forall k st,
          0 <= k < 256 =>
          st <= start{1} < 256 =>
          st <= k < st+2*len{1} =>
            ntt_bound_coefs rp{2} (256 %/ (len{1}))} pre /\
       zeta_{1}  *  (inzmod R) = inzmod (to_sint zeta_0{2}) /\  
       0 <= to_sint zeta_0{2} < Fq.q /\
       start{1} = 2*((k{1}-1) - k1) * len{1} /\
       W64.to_uint cmp{2} = start{1} + len{1} /\ 
       j{1} = to_uint j{2} /\
       start{1} <= j{1} <= start{1} + len{1} /\
       (forall k st,
          0 <= k < 256 =>
          st < start{1} < 256 =>
          st <= k < st+2*len{1} =>
            ntt_bound_coefs rp{2} (9 - log2 len{1} + 1)) /\
       (forall k,
          0 <= k < 256 =>
          ((start{1} + j{1} <= k < start{1} + len{1}) \/
           (start{1} + len{1} +  j{1} <= k < start{1} + len{1} +2*len{1})) =>
            ntt_bound_coefs rp{2} (9 - log2 len{1})));last first. auto => />. 
move => &1 &2 ????????????????????.
split.
split; last by rewrite ultE to_uintD_small; by smt(@W64).
split. 
split; first by rewrite !to_uintD_small of_uintK => />;smt(@IntExtra @W64).
split; first by smt(@W64).
split; last by rewrite to_uintD_small; by smt(@W64). 
by smt(@W64).
split. 
rewrite to_uintD_small => />; first by smt(@W64). 
rewrite H6 => />.
rewrite (_: 
   (to_uint zetasp2 + (k{1} - 1) * 2 + 2) = 
   (to_uint zetasp2 + 2 * k{1} )). by ring. 
rewrite (load_array_from_memE (Glob.mem{2}) ( zetasp2) (k{1})) => />.
smt(@Array256 @ZModP).
move : H0; rewrite /array_mont.
by smt(@ZModP @Array256).
split.
move : H7; rewrite /ntt_bound_zetas => AA; move : (AA (k{1}) _). smt().
rewrite -(load_array_from_memE (Glob.mem{2}) zetasp2). smt().
rewrite (_: to_uint (zetasp{2} + (of_int 2)%W64) = to_uint zetasp2 + 2 * k{1}).
rewrite to_uintD_small; smt(@W64). smt(@W64).
split; first by rewrite to_uintD_small; by smt(@W64). 
by smt(@W64).

move => *.
split.
split; first by rewrite !to_uintD_small => />;  by smt(@W64).
split; last first. 
rewrite (_:to_uint j_R = to_uint start{2} + to_uint len{2}).
smt(). ring. rewrite H14. by ring.
split; first   by smt(@W64).
move => *. 
rewrite (_:to_uint j_R = to_uint start{2} + to_uint len{2}).
smt(@W64).  rewrite H14. 
have stronger : (2*(k{1}+1)*to_uint len{2}  <= 512); smt().
split.  move => * />. 
rewrite ultE /of_uingK => />.
rewrite to_uintD_small. smt(@W64). smt(@W64). 
rewrite ultE /of_uingK => />.
rewrite to_uintD_small. smt(@W64). 
smt(@W64).

wp. sp.
exists* t{2}, zeta_0{2}.
elim* => t2 zeta_02.
call {2} (_:
   to_sint a = to_sint t2 /\ to_sint b = to_sint zeta_02   
   ==> 
  to_sint res = SREDC (to_sint t2 * to_sint zeta_02)
). apply (fqmul_corr (to_sint t2) (to_sint zeta_02)).
skip => />.
move => &1 &2 [#] ?? ?? ?? ?? ?? ?? ??????????????????.
split; last by smt(@W64).
split; last first.
split; first by smt(@W64).
split; first by smt().
(********* bounding carries *)
(* Looser bound *)
move : H8; rewrite /ntt_bound_coefs => AA. 
 move : (AA (to_uint (j{2} + len{2})) _);
 rewrite to_uintD_small; first 3 by smt(@W16).  
 move : (AA (to_uint (j{2})) _); first by smt(@W16).
move => *.

split.
move => *.


move => *.
have ? : (2 <= to_uint len{2}). smt.
have ? : ((9 - log2 (to_uint len{2})) * Fq.q <= 8*Fq.q). smt.

have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2} + to_uint len{2}]<= 8*Fq.q. smt().
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2}]<= 8*Fq.q. smt().

move : (SREDCp_corr (to_sint rp{2}.[to_uint j{2} + to_uint len{2}] * to_sint zeta_0{2}) _ _); first  by smt(@Fq). 
have ? : (-R %/ 2 * Fq.q < -8*Fq.q*Fq.q ); smt(@Fq).

case (k2 <> to_uint j{2} /\ k2 <> to_uint j{2} + to_uint len{2}).
move => *; rewrite !Array256.set_neqiE; smt(@W64). 
case (k2 = to_uint j{2}). 
move => *;rewrite !Array256.set_eqiE; first 2 by smt(@W64). 
rewrite to_sintD_small => /> *.


move => *.  rewrite H27.
 rewrite to_uintD_small; first by smt(@W16).  
have ? : (( Fq.q) + ( 8*Fq.q) < R %/ 2 );   by smt(@Fq). 

move => *.  rewrite H27.
 rewrite to_uintD_small; first by smt(@W16).  
rewrite (_: (10 - log2 (to_uint len{2})) * Fq.q = ( Fq.q) + ( (9 - log2 (to_uint len{2})) * Fq.q)).
by ring.   smt(). 

move => ??.
rewrite (_:k2 = to_uint j{2} + to_uint len{2}); first by smt().
move => *; rewrite Array256.set_neqiE; first 2 by smt(@W64). 
move => *; rewrite Array256.set_eqiE; first 2 by smt(@W64). 
 rewrite to_sintB_small.

move => *.  rewrite H27.
 rewrite to_uintD_small; first by smt(@W16).  
have ? : (( Fq.q) + ( 8*Fq.q) < R %/ 2 );   by smt(@Fq). 

move => *.  rewrite H27.
 rewrite to_uintD_small; first by smt(@W16).  
rewrite (_: (10 - log2 (to_uint len{2})) * Fq.q = ( Fq.q) + ( (9 - log2 (to_uint len{2})) * Fq.q)).
by ring. smt().

(* tighter bound *)
admit.
(*****************)
split; last first. (* More bounds *)  admit. 
(*****************)
(* One goal *)
apply (Array256.ext_eq 
   ((lift_array rp{2}).[to_uint j{2} + to_uint len{2} <-
  ((lift_array rp{2}).[to_uint j{2}] + - zeta_{1} * (lift_array rp{2}).[to_uint j{2} + to_uint len{2}])%ZModP.ZModpRing].[
  to_uint j{2} <-
  (lift_array rp{2}).[to_uint j{2} + to_uint len{2} <-
    ((lift_array rp{2}).[to_uint j{2}] + - zeta_{1} * (lift_array rp{2}).[to_uint j{2} + to_uint len{2}])%ZModP.ZModpRing].[
  to_uint j{2}] + zeta_{1} * (lift_array rp{2}).[to_uint j{2} + to_uint len{2}]])
 (lift_array
  rp{2}.[to_uint (j{2} + len{2}) <- rp{2}.[to_uint j{2}] - result].[to_uint j{2} <- result + rp{2}.[to_uint j{2}]])
).

move => x xb => />.
rewrite !to_uintD_small; first by smt(@W64).
rewrite /lift_array !mapiE => />. split; first by smt(). 
move : H22; rewrite H21.
move :H26; rewrite ultE. move => *.
have ? : 2 * (k{1} - 1 - k1) * to_uint len{2} + to_uint len{2} <= 256; last by smt(). smt(@W64). smt(@W64).


case (x <> to_uint j{2}). 
case (x <> to_uint j{2} + to_uint len{2}); first by smt(@Array256).

move => *.
rewrite Array256.set_neqiE. smt(@W64). smt(@W64).
rewrite Array256.set_eqiE. smt(@W64). smt(@W64).
rewrite Array256.set_neqiE. smt(@W64). smt(@W64).
rewrite Array256.set_eqiE. smt(@W64). smt(@W64).
rewrite to_sintB_small.
(* BOUNDING ONE CARRY *)
move : H8; rewrite /ntt_bound_coefs => AA. 
 move : (AA (to_uint (j{2})) _); first by smt(@W16).
move => *.
have ? : (2 <= to_uint len{2}). smt.
have ? : ((9 - log2 (to_uint len{2})) * Fq.q <= 8*Fq.q). smt.
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2} + to_uint len{2}]<= 8*Fq.q. smt().
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2}]<= 8*Fq.q. smt().

move : (SREDCp_corr (to_sint rp{2}.[to_uint j{2} + to_uint len{2}] * to_sint zeta_0{2}) _ _); first  by smt(@Fq). 
have ? : (-R %/ 2 * Fq.q < -8*Fq.q*Fq.q );  by smt(@Fq).
(************)
rewrite H27 => />.
(***)
 move : (AA (to_uint (j{2})) _); first by smt(@W16).
move => *.
have ? : (2 <= to_uint len{2}). smt.
have ? : ((9 - log2 (to_uint len{2})) * Fq.q <= 8*Fq.q). smt.
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2} + to_uint len{2}]<= 8*Fq.q. smt().
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2}]<= 8*Fq.q. smt().

move : (SREDCp_corr (to_sint rp{2}.[to_uint (j{2} + len{2})] * to_sint zeta_0{2}) _ _); first  by smt(@Fq). 
rewrite to_uintD_small; first by smt(@W16).
have ? : (-R %/ 2 * Fq.q < -8*Fq.q*Fq.q );  by smt(@Fq).
by smt(@Fq).
(**)
rewrite H27.
(***)
move : H8; rewrite /ntt_bound_coefs => AA. 
 move : (AA (to_uint (j{2})) _); first by smt(@W16).
move => *.
have ? : (2 <= to_uint len{2}). smt.
have ? : ((9 - log2 (to_uint len{2})) * Fq.q <= 8*Fq.q). smt.
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2} + to_uint len{2}]<= 8*Fq.q. smt().
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2}]<= 8*Fq.q. smt().

move : (SREDCp_corr (to_sint rp{2}.[to_uint (j{2} + len{2})] * to_sint zeta_0{2}) _ _); first  by smt(@Fq). 
rewrite to_uintD_small; first by smt(@W16).
have ? : (-R %/ 2 * Fq.q < -8*Fq.q*Fq.q );  by smt(@Fq).

rewrite -H27. 
rewrite !inzmodB.
move => *.
rewrite (_: inzmod (to_sint result) = 
   inzmod (to_sint rp{2}.[to_uint (j{2} + len{2})] * to_sint zeta_0{2} * 169)). smt(@ZModP).
rewrite !to_uintD_small; first by smt(@W64).
rewrite !inzmodM -H18. 
rewrite (_: inzmod (to_sint rp{2}.[to_uint j{2} + to_uint len{2}]) * (zeta_{1} * inzmod R) * inzmod 169 = 
     inzmod (to_sint rp{2}.[to_uint j{2} + to_uint len{2}]) * ((zeta_{1} * inzmod R) * inzmod 169)). by ring.
rewrite (_: (zeta_{1} * inzmod R) * inzmod 169 = zeta_{1}). 
smt(@ZModP RRinv).
 by ring.

case (x <> to_uint j{2} + to_uint len{2}); last by smt(@Array256).

move => *.
rewrite (_: x = to_uint j{2}); first by smt().
rewrite Array256.set_eqiE. smt(@W64). smt(@W64).
rewrite Array256.set_neqiE.
move : H22; rewrite H21.
move :H26; rewrite ultE. move => *.
have ? : 2 * (k{1} - 1 - k1) * to_uint len{2} + to_uint len{2} + to_uint len{2} <= 256; last by smt().
 smt(@W64).
 smt(@W64).


rewrite Array256.set_eqiE. smt(@W64). smt(@W64).
rewrite to_sintD_small. 
(* BOUNDING ONE CARRY *)
move : H8; rewrite /ntt_bound_coefs => AA. 
 move : (AA (to_uint (j{2})) _); first by smt(@W16).
move => *.
have ? : (2 <= to_uint len{2}). smt.
have ? : ((9 - log2 (to_uint len{2})) * Fq.q <= 8*Fq.q). smt.
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2} + to_uint len{2}]<= 8*Fq.q. smt().
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2}]<= 8*Fq.q. smt().

move : (SREDCp_corr (to_sint rp{2}.[to_uint j{2} + to_uint len{2}] * to_sint zeta_0{2}) _ _); first  by smt(@Fq). 
have ? : (-R %/ 2 * Fq.q < -8*Fq.q*Fq.q );  by smt(@Fq).
(************)
rewrite H27 => />.
(***)
 move : (AA (to_uint (j{2})) _); first by smt(@W16).
move => *.
have ? : (2 <= to_uint len{2}). smt.
have ? : ((9 - log2 (to_uint len{2})) * Fq.q <= 8*Fq.q). smt.
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2} + to_uint len{2}]<= 8*Fq.q. smt().
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2}]<= 8*Fq.q. smt().

move : (SREDCp_corr (to_sint rp{2}.[to_uint (j{2} + len{2})] * to_sint zeta_0{2}) _ _); first  by smt(@Fq). 
rewrite to_uintD_small; first by smt(@W16).
have ? : (-R %/ 2 * Fq.q < -8*Fq.q*Fq.q );  by smt(@Fq).
by smt(@Fq).
(**)
rewrite H27.
(***)
move : H8; rewrite /ntt_bound_coefs => AA. 
 move : (AA (to_uint (j{2})) _); first by smt(@W16).
move => *.
have ? : (2 <= to_uint len{2}). smt.
have ? : ((9 - log2 (to_uint len{2})) * Fq.q <= 8*Fq.q). smt.
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2} + to_uint len{2}]<= 8*Fq.q. smt().
have ? : -8*Fq.q <=  to_sint rp{2}.[to_uint j{2}]<= 8*Fq.q. smt().

move : (SREDCp_corr (to_sint rp{2}.[to_uint (j{2} + len{2})] * to_sint zeta_0{2}) _ _); first  by smt(@Fq). 
rewrite to_uintD_small; first by smt(@W16).
have ? : (-R %/ 2 * Fq.q < -8*Fq.q*Fq.q );  by smt(@Fq).

rewrite -H27. 
rewrite !inzmodD.
move => *.
rewrite (_: inzmod (to_sint result) = 
   inzmod ((to_sint rp{2}.[to_uint (j{2} + len{2})] * to_sint zeta_0{2} * 169))). smt(@ZModP).
rewrite !to_uintD_small; first by smt(@W64).
rewrite !inzmodM -H18. 
rewrite (_: inzmod (to_sint rp{2}.[to_uint j{2} + to_uint len{2}]) * (zeta_{1} * inzmod R) * inzmod 169 = 
     inzmod (to_sint rp{2}.[to_uint j{2} + to_uint len{2}]) * ((zeta_{1} * inzmod R) * inzmod 169)). by ring.
rewrite (_: (zeta_{1} * inzmod R) * inzmod 169 = zeta_{1}). 
smt(@ZModP RRinv).
ring. 
smt(@ZModP @Array256).
qed.

end KyberPoly.
