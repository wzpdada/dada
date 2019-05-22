设置 -e

USER = “备份”
密码= “备份”
＃数据库数据目录＃
DATA_DIR = “ / data / mysql ”
BIN_INDEX = $ DATA_DIR “ /mysql-bin.index ”
＃备份目录＃
BACKUP_DIR = “ / data / backup / mysql ”
BACKUP_LOG = “ /var/log/mysql/backup.log ”

DATE = ` date + “％Y％m％d ” `
TIME = ` date + “％Y％m％d％H ” `

LOG_TIME = ` date + “％Y-％m-％d％H：％M：％S ” `
DELETE_BINLOG_TIME = “ 7天”
INCREMENT_INTERVAL = “ 3小时”

note（）{
    printf  “ [ $ LOG_TIME ]注意：$ * \ n ”  >>  $ BACKUP_LOG ;
}

警告（）{
    printf  “ [ $ LOG_TIME ]警告：$ * \ n ”  >>  $ BACKUP_LOG ;
}

error（）{
    printf  “ [ $ LOG_TIME ]错误：$ * \ n ”  >>  $ BACKUP_LOG ;
    1 号出口;
}

full_backup（）{
    local dbs = ` ls -l $ DATA_DIR  | grep “ ^ d ”  | awk -F “  ”  ' {print $ 9} ' `

    for  db  in  $ dbs
    做
        本地 backup_dir = $ BACKUP_DIR “ / full / ” $ db
        本地文件名= $ db “。” $ DATE
        local backup_file = $ backup_dir “ / ” $ filename “ .sql ”

        如果 [ ！ -d  $ backup_dir ]
        然后
            mkdir -p $ backup_dir  || {error “创建数据库$ db全量备份目录$ backup_dir失败” ;  继续; }
            注意“数据库$ db全量备份目录$ backup_dir   不存在，创建完成” ;
        科幻

        注意“完全备份$ db start ... ”
        mysqldump --user = $ {USER} --password = $ {PASSWORD} --flush-logs --skip-lock-tables --quick $ db  >  $ backup_file  || {warning “数据库$ db备份失败” ;  继续; }

        cd  $ backup_dir
        tar -cPzf $ filename “ .tar.gz ”  $ filename “ .sql ”
        rm -f $ backup_file
        chown -fR mysql：mysql $ backup_dir

        注意“数据库$ db备份成功” ;
        注意“完全备份$ db end。”
    DONE
}

increment_backup（）{
    local StartTime = ` date “ -d $ INCREMENT_INTERVAL前” + “％Y-％m-％d％H：％M：％S ” `
    local DELETE_BINLOG_END_TIME = ` date “ -d $ DELETE_BINLOG_TIME前” + “％Y-％m-％d％H：％M：％S ” `
    local dbs = ` ls -l $ DATA_DIR  | grep “ ^ d ”  | awk -F “  ”  ' {print $ 9} ' `

    MySQL的-u $ USER -p $ PASSWORD -e “之前， '清除主日志$ DELETE_BINLOG_END_TIME ' ”  &&注意“删除$ DELETE_BINLOG_TIME日之前登录” ;

    filename = ` cat $ BIN_INDEX  | awk -F “ / ”  ' {print $ 2} ' `
    对于 我 在 $文件名
    做
        for  db  in  $ dbs
        做
            本地 backup_dir = $ BACKUP_DIR “ / increment / ” $ db
            本地文件名= $ db “。” $ TIME
            local backup_file = $ backup_dir “ / ” $ filename “ .sql ”

            如果 [ ！ -d  $ backup_dir ]
            然后
                mkdir -p $ backup_dir  || {error “创建数据库$ db增量备份目录$ backup_dir失败” ;  继续; }
                请注意“数据库$ db增量备份目录$ backup_dir   不存在，创建完成” ;
            科幻

            注意“增量备份$ db表单时间$ StartTime start ... ”

            mysqlbinlog -d $ db --start-datetime = “ $ StartTime ”  $ DATA_DIR / $ i  >>  $ backup_file  || {warning “数据库$ db备份失败” ;  继续; }

            注意“增量备份$ db end。”
        DONE
    DONE

    for  db  in  $ dbs
    做
        本地 backup_dir = $ BACKUP_DIR “ / increment / ” $ db
        本地文件名= $ db “。” $ TIME
        local backup_file = $ backup_dir “ / ” $ filename “ .sql ”

        cd  $ backup_dir
        tar -cPzf $ filename “ .tar.gz ”  $ filename “ .sql ”
        rm -f $ backup_file

        注意“数据库$ db备份成功” ;
    DONE
}

案例 “ $ 1 ”  in
    充分）
        full_backup
    ;;
    增量）
        increment_backup
    ;;
    *）
        出口 2
    ;;
ESAC
