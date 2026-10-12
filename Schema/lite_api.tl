int ? = Int;
long ? = Long;
string ? = String;
object ? = Object;
bytes data:string = Bytes;

vector {t:Type} # [ t ] = Vector t;
int256 8*[ int ] = Int256;

tonNode.blockIdExt workchain:int shard:long
    seqno:int root_hash:int256 file_hash:int256 = tonNode.BlockIdExt;

adnl.message.query query_id:int256 query:bytes = adnl.Message;
adnl.message.answer query_id:int256 answer:bytes = adnl.Message;

liteServer.error code:int message:string = liteServer.Error;
liteServer.accountId workchain:int id:int256 = liteServer.AccountId;

liteServer.sendMsgStatus status:int = liteServer.SendMsgStatus;

liteServer.accountState id:tonNode.blockIdExt shardblk:tonNode.blockIdExt
    shard_proof:bytes proof:bytes state:bytes = liteServer.AccountState;

liteServer.runMethodResult mode:# id:tonNode.blockIdExt shardblk:tonNode.blockIdExt
    shard_proof:mode.0?bytes proof:mode.0?bytes state_proof:mode.1?bytes init_c7:mode.3?bytes
    lib_extras:mode.4?bytes exit_code:int result:mode.2?bytes = liteServer.RunMethodResult;

liteServer.transactionInfo id:tonNode.blockIdExt proof:bytes transaction:bytes = liteServer.TransactionInfo;
liteServer.transactionList ids:(vector tonNode.blockIdExt) transactions:bytes = liteServer.TransactionList;

---functions---

liteServer.sendMessage body:bytes = liteServer.SendMsgStatus;
liteServer.getAccountState id:tonNode.blockIdExt account:liteServer.accountId = liteServer.AccountState;
liteServer.runSmcMethod mode:# id:tonNode.blockIdExt account:liteServer.accountId method_id:long params:bytes = liteServer.RunMethodResult;
liteServer.getOneTransaction id:tonNode.blockIdExt account:liteServer.accountId lt:long = liteServer.TransactionInfo;
liteServer.getTransactions count:# account:liteServer.accountId lt:long hash:int256 = liteServer.TransactionList;

liteServer.query data:bytes = Object;
