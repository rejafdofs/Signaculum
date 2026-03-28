-- Signaculum.Sakura.Signum
-- シグヌム型の集約ファスキクルスにゃん♪ 全てのカテゴリーを一つにまとめるにゃ

import Signaculum.Sakura.Signum.Scopi
import Signaculum.Sakura.Signum.Superficiei
import Signaculum.Sakura.Signum.Exhibitionis
import Signaculum.Sakura.Signum.Morae
import Signaculum.Sakura.Signum.Optionum
import Signaculum.Sakura.Signum.Imperii
import Signaculum.Sakura.Signum.Formae
import Signaculum.Sakura.Signum.Bullae
import Signaculum.Sakura.Signum.Fenestrae
import Signaculum.Sakura.Signum.Inputi
import Signaculum.Sakura.Signum.Soni
import Signaculum.Sakura.Signum.Eventuum
import Signaculum.Sakura.Signum.Animationis
import Signaculum.Sakura.Signum.Mutationis
import Signaculum.Sakura.Signum.Retis
import Signaculum.Sakura.Signum.Modorum
import Signaculum.Sakura.Signum.Proprietatis

namespace Signaculum.Sakura

/-- サクラスクリプトの構造化タグにゃん。
    全てのサクラスクリプトタグをカテゴリー別の子帰納型でラップするにゃ。
    文字列への變換は `adCatenam` で行ふにゃん♪ -/
inductive Signum where
  | scopi         : SignumScopi → Signum
  | superficiei   : SignumSuperficiei → Signum
  | exhibitionis  : SignumExhibitionis → Signum
  | morae         : SignumMorae → Signum
  | optionum      : SignumOptionum → Signum
  | imperii       : SignumImperii → Signum
  | formae        : SignumFormae → Signum
  | bullae        : SignumBullae → Signum
  | fenestrae     : SignumFenestrae → Signum
  | inputi        : SignumInputi → Signum
  | soni          : SignumSoni → Signum
  | eventuum      : SignumEventuum → Signum
  | animationis   : SignumAnimationis → Signum
  | mutationis    : SignumMutationis → Signum
  | retis         : SignumRetis → Signum
  | modorum       : SignumModorum → Signum
  | proprietatis  : SignumProprietatis → Signum
  deriving Repr

/-- シグヌムをサクラスクリプト文字列に變換するにゃん -/
def Signum.adCatenam : Signum → String
  | .scopi s         => s.adCatenam
  | .superficiei s   => s.adCatenam
  | .exhibitionis s  => s.adCatenam
  | .morae s         => s.adCatenam
  | .optionum s      => s.adCatenam
  | .imperii s       => s.adCatenam
  | .formae s        => s.adCatenam
  | .bullae s        => s.adCatenam
  | .fenestrae s     => s.adCatenam
  | .inputi s        => s.adCatenam
  | .soni s          => s.adCatenam
  | .eventuum s      => s.adCatenam
  | .animationis s   => s.adCatenam
  | .mutationis s    => s.adCatenam
  | .retis s         => s.adCatenam
  | .modorum s       => s.adCatenam
  | .proprietatis s  => s.adCatenam

instance : ToString Signum := ⟨Signum.adCatenam⟩

/-- シグヌムのリストゥスをサクラスクリプト文字列に變換するにゃん。
    全てのシグヌムの adCatenam を連結するにゃ♪ -/
def adCatenamLista (signa : List Signum) : String :=
  String.join (signa.map Signum.adCatenam)

end Signaculum.Sakura
