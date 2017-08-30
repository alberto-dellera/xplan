--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era                                                                    
-- Copyright:   (c) 2013 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------
                                                                                                   
-- sqlid+child_number whose counts are over threshold (m_ash_thr)                                  
&COMM_IF_LT_10G. type ash_info_t is record (
&COMM_IF_LT_10G.   sample_time_min timestamp(3),                                                   
&COMM_IF_LT_10G.   sample_time_max timestamp(3),                                                                                
&COMM_IF_LT_10G.   cnt             int -- count(*)                            
&COMM_IF_LT_10G. ); 

&COMM_IF_LT_10G. type ash_over_thr_t is table of ash_info_t index by varchar2(100 char);
&COMM_IF_LT_10G. m_ash_over_thr ash_over_thr_t;
&COMM_IF_LT_10G. m_ash_cnt_thr number := 10;
&COMM_IF_LT_10G. m_ash_over_thr_initialized boolean := false;
