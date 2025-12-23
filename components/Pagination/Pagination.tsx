import css from './Pagination.module.css';

interface PaginationProps {
  page: number;
  totalPages: number;
  onChange: (page: number) => void;
}

export default function Pagination({ page, totalPages, onChange }: PaginationProps) {
  if (totalPages <= 1) return null;

  return (
    <div className={css.pagination}>
      <button
        className={css.button}
        onClick={() => onChange(page - 1)}
        disabled={page === 1}
      >
        Previous
      </button>
      <span className={css.info}>
        Page {page} of {totalPages}
      </span>
      <button
        className={css.button}
        onClick={() => onChange(page + 1)}
        disabled={page === totalPages}
      >
        Next
      </button>
    </div>
  );
}